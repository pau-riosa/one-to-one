defmodule Todo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Membrane.Logger

  alias Membrane.TelemetryMetrics.Reporter

  @cert_file_path "priv/integrated_turn_cert.pem"
  @impl true
  def start(_type, _args) do
    config_common_dtls_key_cert()
    create_integrated_turn_cert_file()

    children = [
      {Reporter, [metrics: Membrane.RTC.Engine.Metrics.metrics(), name: TodoRoomReporter]},
      # Start the Ecto repository
      Todo.Repo,
      # Start the Telemetry supervisor
      TodoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Todo.PubSub},
      # start presence 
      TodoWeb.Presence,
      # Start the Endpoint (http/https)
      TodoWeb.Endpoint
      # Start a worker by calling: Todo.Worker.start_link(arg)
      # {Todo.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Todo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TodoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @impl true
  def stop(_state) do
    delete_cert_file()
    :ok
  end

  defp create_integrated_turn_cert_file() do
    cert_path = Application.fetch_env!(:todo, :integrated_turn_cert)
    pkey_path = Application.fetch_env!(:todo, :integrated_turn_pkey)

    if cert_path != nil and pkey_path != nil do
      cert = File.read!(cert_path)
      pkey = File.read!(pkey_path)

      File.touch!(@cert_file_path)
      File.chmod!(@cert_file_path, 0o600)
      File.write!(@cert_file_path, "#{cert}\n#{pkey}")

      Application.put_env(:todo, :integrated_turn_cert_pkey, @cert_file_path)
    else
      Membrane.Logger.warn("""
      Integrated TURN certificate or private key path not specified.
      Integrated TURN will not handle TLS connections.
      """)
    end
  end

  defp delete_cert_file(), do: File.rm(@cert_file_path)

  defp config_common_dtls_key_cert() do
    {:ok, pid} = ExDTLS.start_link(client_mode: false, dtls_srtp: true)
    {:ok, pkey} = ExDTLS.get_pkey(pid)
    {:ok, cert} = ExDTLS.get_cert(pid)
    :ok = ExDTLS.stop(pid)
    Application.put_env(:todo, :dtls_pkey, pkey)
    Application.put_env(:todo, :dtls_cert, cert)
  end
end

defmodule Todo do
  @moduledoc """
  Todo keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  The main interface for shared functionality.
  """
  require Logger

  @doc """
  Looks up `Application` config or raises if keyspace is not configured.
  ## Examples
      config :todo, :files, [
        uploads_dir: Path.expand("../priv/uploads", __DIR__),
        host: [scheme: "http", host: "localhost", port: 4000],
      ]
      iex> Todo.config([:files, :uploads_dir])
      iex> Todo.config([:files, :host, :port])
  """
  def config([main_key | rest] = keyspace) when is_list(keyspace) do
    main = Application.fetch_env!(:todo, main_key)

    Enum.reduce(rest, main, fn next_key, current ->
      case Keyword.fetch(current, next_key) do
        {:ok, val} -> val
        :error -> raise ArgumentError, "no config found under #{inspect(keyspace)}"
      end
    end)
  end

  @doc """
  Be able to upload files/media
  """
  def upload_files(socket) do
    import Phoenix.LiveView, only: [consume_uploaded_entries: 3]
    alias TodoWeb.Router.Helpers, as: Routes

    consume_uploaded_entries(socket, :file, fn %{path: path}, entry ->
      dir = Todo.config([:files, :uploads_dir])
      dest = Path.join(dir, "#{entry.uuid}.#{ext(entry)}")
      store_file(dest, path)

      {:ok, Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")}
    end)
  end

  def store_file(destination, path) do
    File.mkdir_p!(Path.dirname(destination))
    File.cp!(path, destination)
  end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end
end

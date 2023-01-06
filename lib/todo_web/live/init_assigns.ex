defmodule TodoWeb.Live.InitAssigns do
  @moduledoc """
  To setup initial assigns
  """
  use TodoWeb, :live_view

  alias Todo.Accounts

  def on_mount(:private, _params, %{"user_token" => user_token} = _session, socket) do
    timezone = get_connect_params(socket)["timezone"] || "Etc/UTC"
    current_user = Accounts.get_user_by_session_token(user_token)

    active_tab =
      case socket.view do
        TodoWeb.DashboardLive -> :dashboard
        TodoWeb.BookingLive -> :bookings
        TodoWeb.AvailabilityLive -> :availability
        TodoWeb.SettingsLive -> :settings
        _ -> nil
      end

    socket =
      socket
      |> assign(timezone: timezone)
      |> assign(current_user: current_user)
      |> assign(active_tab: active_tab)

    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket) do
    timezone = get_connect_params(socket)["timezone"] || "Etc/UTC"

    socket =
      socket
      |> assign(timezone: timezone)
      |> assign(current_user: nil)

    {:cont, socket}
  end
end

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

    active_url =
      case socket.view do
        TodoWeb.DashboardLive -> Routes.dashboard_path(socket, :index)
        TodoWeb.BookingLive -> Routes.booking_path(socket, :index)
        TodoWeb.AvailabilityLive -> Routes.availability_path(socket, :index)
        TodoWeb.SettingsLive -> Routes.settings_path(socket, :index)
        _ -> nil
      end

    socket =
      socket
      |> assign(timezone: timezone)
      |> assign(current_user: current_user)
      |> assign(active_tab: active_tab)
      |> assign(active_url: active_url)

    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket) do
    timezone =
      if connected?(socket) do
        get_connect_params(socket)["timezone"]
      else
        "Etc/UTC"
      end

    socket =
      socket
      |> assign(timezone: timezone)
      |> assign(current_user: nil)

    {:cont, socket}
  end
end

defmodule TodoWeb.DashboardLive do
  use TodoWeb, :live_view

  alias Todo.Schedules

  @impl true
  def mount(_params, _session, socket) do
    upcoming_session_count =
      Schedules.get_upcoming_session_count(
        socket.assigns.current_user.id,
        socket.assigns.timezone
      )

    total_session_duration =
      Schedules.get_total_session_duration(socket.assigns.current_user.id) || 0

    total_bookings = Schedules.get_total_bookings(socket.assigns.current_user.id) || 0

    {:ok,
     assign(socket,
       page_title: "Home",
       total_session_duration: total_session_duration,
       total_bookings: total_bookings,
       upcoming_session_count: upcoming_session_count,
       active_url: socket.assigns.active_url
     )}
  end
end

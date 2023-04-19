defmodule TodoWeb.BookingLive do
  use TodoWeb, :live_view

  alias Todo.Schedules

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      TodoWeb.Endpoint.subscribe("events")
    end

    {:ok, assign(socket, page_title: "Bookings", active_url: socket.assigns.active_url)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> Schedules.assign_dates(params)
      |> Schedules.get_current_schedules(params)
      |> handle_tab(params)
      |> assign(:page_title, "Bookings")

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "new_schedule", payload: %{event_id: _event_id}}, socket) do
    {:noreply, Schedules.get_current_schedules(socket, %{})}
  end

  def handle_tab(socket, params) do
    active_tab =
      case params["session"] do
        "past" -> "past"
        _ -> "upcoming"
      end

    assign(socket, :active_selection, active_tab)
  end

  def handle_scheduled_for(scheduled_for, timezone \\ "Etc/UTC") do
    scheduled_for
    |> Timex.to_datetime(timezone)
    |> Timex.format!("%A %B %e, %Y %l:%M %p", :strftime)
  end
end

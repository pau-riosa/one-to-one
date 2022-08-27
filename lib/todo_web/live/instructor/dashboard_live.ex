defmodule TodoWeb.Instructor.DashboardLive do
  use TodoWeb, :live_view

  alias __MODULE__
  alias Todo.Schedules
  alias TodoWeb.Components.CalendarMonths
  alias TodoWeb.Presence
  alias Todo.PubSub

  @presence "todo:dashboard"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      TodoWeb.Endpoint.subscribe("events")
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> Schedules.assign_dates(params)
      |> Schedules.get_current_schedules(params)
      |> handle_tab(params)
      |> assign(:page_title, "Dashboard")

    {:noreply, socket}
  end

  def handle_info(%{event: "new_event", payload: %{event_id: _event_id}}, socket) do
    {:noreply, Schedules.get_current_schedules(socket, %{})}
  end

  def handle_tab(socket, params) do
    active_tab =
      case params["class"] do
        "past" -> "past"
        _ -> "upcoming"
      end

    assign(socket, :active_tab, active_tab)
  end
end

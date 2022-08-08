defmodule TodoWeb.Instructor.DashboardLive do
  use TodoWeb, :live_view

  alias __MODULE__
  alias Todo.Schedules
  alias TodoWeb.Components.CalendarMonths

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> Schedules.assign_dates(params)
      |> Schedules.get_current_schedules(params)
      |> handle_tab(params)

    {:noreply, socket}
  end

  def handle_tab(socket, params) do
    assign(socket, :active_tab, params["class"])
  end
end

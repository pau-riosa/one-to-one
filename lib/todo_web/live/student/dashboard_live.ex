defmodule TodoWeb.Student.DashboardLive do
  use TodoWeb, :live_view

  alias Todo.Schedules

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket = Schedules.assign_dates(socket, params)
    {:noreply, socket}
  end
end

defmodule TodoWeb.DashboardLive do
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

    {:ok, assign(socket, page_title: "Home")}
  end
end

defmodule TodoWeb.AvailabilityLive do
  use TodoWeb, :live_view

  alias Todo.Schemas.User

  def mount(_params, _session, socket) do
    {:ok, assign(socket, view: :availability_hours, page_title: "Availability Hours")}
  end

  def handle_event("show-available-hours", _, socket) do
    {:noreply, assign(socket, view: :availability_hours, page_title: "Availability Hours")}
  end
end

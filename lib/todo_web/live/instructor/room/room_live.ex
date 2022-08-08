defmodule TodoWeb.Instructor.RoomLive do
  use TodoWeb, :live_view

  @impl true
  def mount(%{"event_id" => event_id} = _params, _session, socket) do
    event = Todo.Repo.get(Todo.Events.Event, event_id)

    socket =
      socket
      |> assign(:event_id, event_id)
      |> assign(:event, event)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"event_id" => event_id} = _params, _uri, socket) do
    socket =
      socket
      |> assign(:event_id, event_id)

    {:noreply, socket}
  end
end

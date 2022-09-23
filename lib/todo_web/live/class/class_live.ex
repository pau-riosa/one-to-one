defmodule TodoWeb.ClassLive do
  use TodoWeb, :live_view
  alias Todo.Events
  alias Todo.Events.Event

  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    events = Events.get_events_by_created_by_id(user.id)

    {:ok,
     socket
     |> assign(:events, events)}
  end

  def handle_event(
        "delete-event",
        %{"id" => id} = _params,
        %{assigns: %{current_user: user}} = socket
      ) do
    case Events.delete(id) do
      {:ok, %Event{} = event} ->
        events = Events.get_events_by_created_by_id(user.id)
        {:noreply, socket |> assign(:events, events)}

      {:error, error} ->
        {:noreply, socket}
    end
  end
end

defmodule TodoWeb.Instructor.Event.New do
  use TodoWeb, :live_component

  alias Todo.Events.{Event, Operation}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params} = _params, socket) do
    changeset =
      %Event{}
      |> Event.changeset(event_params)
      |> Map.put(:action, :validate)

    socket = assign(socket, :changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("save", %{"event" => event_params} = _params, socket) do
    changeset =
      %Event{}
      |> Event.changeset(event_params)
      |> Operation.call()
      |> case do
        {:ok, event} ->
          socket =
            socket
            |> put_flash(:info, "Event created.")
            |> push_redirect(to: Routes.event_path(socket, :create_schedule, event.id))

          {:noreply, socket}

        {:error, changeset} ->
          socket =
            socket
            |> assign(:changeset, changeset)

          {:noreply, socket}
      end
  end
end

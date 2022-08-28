defmodule TodoWeb.Instructor.Event.Edit do
  use TodoWeb, :live_component

  alias Todo.Events.{Event, Operation}
  alias Todo.Repo

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:file, accept: :any, max_entries: 3)}
  end

  @impl true
  def handle_event("cancel-entry", %{"ref" => ref} = _params, socket) do
    {:noreply, cancel_upload(socket, :file, ref)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params} = _params, socket) do
    changeset =
      socket.assigns.event
      |> Event.changeset(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"event" => event_params} = _params, socket) do
    uploaded_files =
      socket
      |> Todo.upload_files()
      |> case do
        [] -> socket.assigns.event.files
        uploaded_files -> uploaded_files ++ socket.assigns.event.files
      end

    event_params = Map.put(event_params, "files", uploaded_files)

    socket.assigns.event
    |> Operation.update(event_params)
    |> case do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event update.")
         |> push_redirect(to: Routes.instructor_dashboard_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def preload(list_of_assigns) do
    Enum.map(list_of_assigns, fn assigns ->
      event = Repo.get(Event, assigns.event_id)
      Map.put(assigns, :event, event)
    end)
  end
end

defmodule TodoWeb.Event.New do
  use TodoWeb, :live_component

  alias Todo.Events.{Event, Operation}

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:file, accept: :any, max_entries: 3)
     |> assign(:page_title, "Create New Event")}
  end

  @impl true
  def handle_event("cancel-entry", %{"ref" => ref} = _params, socket) do
    {:noreply, cancel_upload(socket, :file, ref)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params} = _params, socket) do
    changeset =
      %Event{}
      |> Event.changeset(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"event" => event_params} = _params, socket) do
    uploaded_files = Todo.upload_files(socket)

    event_params = Map.put(event_params, "files", uploaded_files)

    %Event{}
    |> Operation.insert(event_params)
    |> case do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created.")
         |> push_redirect(to: Routes.event_path(socket, :create_schedule, event.id))}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_event(
        "comma",
        %{"key" => ",", "value" => value} = _params,
        socket
      ) do
    [value, _] = String.split(value, ",")

    socket =
      socket
      |> assign(:invitees, [value | socket.assigns.invitees])

    {:noreply, socket}
  end

  @impl true
  def handle_event("comma", _params, socket) do
    {:noreply, socket}
  end

  # def validate_email(value) do
  #   case Regex.run(~r/^[^\s]+@[^\s]+$/, value) do
  #     nil ->
  #       {:error, nil}

  #     [email] ->
  #       {:ok, email}
  #   end
  # end
end

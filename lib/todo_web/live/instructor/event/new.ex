defmodule TodoWeb.Instructor.Event.New do
  use TodoWeb, :live_component

  alias Todo.Events.{Event, Operation}

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:file, accept: :any, max_entries: 3)

    {:ok, socket}
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

    socket = assign(socket, :changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("save", %{"event" => event_params} = _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :file, fn %{path: path}, entry ->
        dest = Path.join("priv/static/uploads", "#{entry.uuid}.#{ext(entry)}")
        File.cp!(path, dest)
        {:ok, Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")}
      end)

    event_params = Map.put(event_params, "files", uploaded_files)

    %Event{}
    |> Event.changeset(event_params)
    |> Operation.insert()
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

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end
end
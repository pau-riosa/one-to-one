defmodule TodoWeb.Book.SetSchedule do
  use TodoWeb, :live_component

  alias Todo.Schemas.Schedule
  alias Todo.Operations.Schedule, as: Operation

  def mount(socket) do
    changeset = Schedule.changeset(%Schedule{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def preload(list_of_assigns) do
    Enum.map(list_of_assigns, fn assigns ->
      scheduled_for =
        case DateTime.from_iso8601(assigns[:schedule]) do
          {:ok, schedule, _} -> schedule
          _ -> 0
        end

      start_time =
        case DateTime.from_iso8601(assigns[:schedule]) do
          {:ok, schedule, _} ->
            schedule
            |> Timex.to_datetime(assigns[:timezone])
            |> Timex.format!("{WDshort} {Mfull} {D}, {YYYY} {h12}:{m} {AM}")

          _ ->
            0
        end

      duration = assigns[:book_with].duration

      end_time =
        case DateTime.from_iso8601(assigns[:schedule]) do
          {:ok, schedule, _} ->
            schedule
            |> Timex.to_datetime(assigns[:timezone])
            |> Timex.shift(minutes: duration)
            |> Timex.format!("{h12}:{m} {AM}")

          _ ->
            0
        end

      assigns
      |> Map.put(:start_time, start_time)
      |> Map.put(:end_time, end_time)
      |> Map.put(:duration, duration)
      |> Map.put(:scheduled_for, scheduled_for)
    end)
  end

  def handle_event("validate", %{"schedule" => schedule_params} = _params, socket) do
    changeset =
      %Schedule{}
      |> Schedule.changeset(schedule_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"schedule" => schedule_params} = _params, socket) do
    case Operation.prepare_session(schedule_params, socket) do
      {:ok, %Schedule{}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Schedule created.")
         |> push_redirect(to: Routes.book_path(socket, :index, socket.assigns.book_with.slug))}

      {:error, :email_cannot_be_the_same} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid invitee email.")
         |> push_redirect(to: Routes.book_path(socket, :index, socket.assigns.book_with.slug))}

      {:error, :cannot_create_participant} ->
        {:noreply, socket}

      {:error, :cannot_create_meeting} ->
        {:noreply, socket}

      {:error, _, changeset, _} ->
        {:noreply, assign(socket, :changeset, changeset)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}

      _errors ->
        {:noreply, socket}
    end
  end
end

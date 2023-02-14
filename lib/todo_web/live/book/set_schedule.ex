defmodule TodoWeb.Book.SetSchedule do
  use TodoWeb, :live_component

  alias Todo.Schemas.Schedule
  alias Todo.Schedules.Operation
  alias Todo.Helpers.UserNotifier

  def mount(socket) do
    changeset = Schedule.set_schedule_changeset(%Schedule{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def handle_event("validate", %{"schedule" => schedule_params} = _params, socket) do
    changeset =
      %Schedule{}
      |> Schedule.set_schedule_changeset(schedule_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"schedule" => schedule_params} = _params, socket) do
    %Schedule{}
    |> Operation.create_schedule(schedule_params)
    |> case do
      {:ok, schedule} ->
        schedule =
          schedule
          |> Todo.Repo.preload(:created_by)

        UserNotifier.deliver_schedule_instructions(
          schedule,
          TodoWeb.Router.Helpers.url(socket) <>
            Routes.room_path(socket, :index, schedule)
        )

        {:noreply,
         socket
         |> put_flash(:info, "Schedule successfully booked.")
         |> push_redirect(to: "/")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
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
            schedule =
              schedule
              |> Timex.to_datetime(assigns[:timezone])
              |> Timex.format!("{WDfull} {Mfull} {D}, {YYYY} {h12}")

          _ ->
            0
        end

      duration = assigns[:book_with].duration

      end_time =
        case DateTime.from_iso8601(assigns[:schedule]) do
          {:ok, schedule, _} ->
            schedule =
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
end

defmodule TodoWeb.Book.SetSchedule do
  use TodoWeb, :live_component

  alias Todo.Schemas.Schedule
  alias Todo.Schedules.Operation
  alias Todo.Helpers.UserNotifier
  alias Ecto.Multi

  def mount(socket) do
    changeset = Schedule.set_schedule_changeset(%Schedule{})
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

  def handle_event("validate", %{"schedule" => schedule_params} = _params, socket) do
    changeset =
      %Schedule{}
      |> Schedule.set_schedule_changeset(schedule_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"schedule" => schedule_params} = _params, socket) do
    case prepare_meeting(schedule_params) do
      {:ok, %{create_schedule: schedule, participant: participant}} ->
        schedule = Todo.Repo.preload(schedule, :created_by)

        UserNotifier.deliver_schedule_instructions(
          schedule,
          TodoWeb.Router.Helpers.url(socket) <>
            Routes.room_path(
              socket,
              :index,
              schedule.id,
              participant.participant_id,
              participant.meeting_id
            )
        )

        {:noreply,
         socket
         |> put_flash(:info, "Schedule successfully booked.")
         |> push_redirect(to: "/")}

      {:error, _, changeset, _} ->
        {:noreply, assign(socket, :changeset, changeset)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp prepare_meeting(schedule_params) do
    Multi.new()
    |> Multi.run(:create_schedule, fn repo, _ ->
      Todo.Operations.Schedule.create(schedule_params, repo)
    end)
    |> Multi.run(:create_meeting, fn repo, %{create_schedule: schedule} ->
      Todo.Operations.Meeting.create_dyte_meeting(schedule, repo)
    end)
    |> Multi.run(:participant, fn repo,
                                  %{
                                    create_meeting: meeting,
                                    create_schedule: schedule
                                  } ->
      schedule = schedule |> repo.preload(:created_by)

      Todo.Operations.Participant.create_dyte_participant(
        %{
          schedule: schedule,
          email: schedule_params["email"],
          meeting_id: meeting.meeting_id,
          participant_name: schedule_params["name"],
          preset_name: "basic-version-1"
        },
        repo
      )
    end)
    |> Multi.run(:meeting_owner, fn repo,
                                    %{
                                      create_meeting: meeting,
                                      create_schedule: schedule
                                    } ->
      schedule = schedule |> repo.preload(:created_by)

      Todo.Operations.Participant.create_dyte_participant(
        %{
          schedule: schedule,
          email: schedule.created_by.email,
          meeting_id: meeting.meeting_id,
          participant_name: "#{schedule.created_by.first_name} #{schedule.created_by.last_name}",
          preset_name: "basic-version-1"
        },
        repo
      )
    end)
    |> Todo.Repo.transaction()
  end
end

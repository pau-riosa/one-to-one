defmodule Todo.Operations.Schedule do
  @moduledoc false
  alias Todo.Schemas.Schedule, as: Schema
  alias Todo.Schemas.User
  alias Todo.Repo
  alias Ecto.Multi
  alias Todo.Helpers.UserNotifier
  alias TodoWeb.Router.Helpers, as: Routes

  def changeset(struct \\ %Schema{}, params \\ %{}) do
    Schema.changeset(struct, params)
  end

  def create_schedule(params, repo \\ Repo) do
    with {:ok, params} <- check_email(params, repo) do
      %Schema{}
      |> Schema.changeset(params)
      |> Map.put(:action, :insert)
      |> repo.insert()
    end
  end

  def prepare_session(schedule_params, socket) do
    with _dyte_initialization <- dyte_integration_module().initialize(),
         {:ok, %{create_schedule: schedule, participant: participant}} <-
           dyte_integration(schedule_params) do
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

      {:ok, schedule}
    else
      {:error, :cannot_create_participant} ->
        {:error, :cannot_create_participant}

      {:error, :cannot_create_meeting} ->
        {:error, :cannot_create_meeting}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp check_email(%{"email" => email, "created_by_id" => created_by_id} = params, repo) do
    %{email: schedule_owner_email} = repo.get(User, created_by_id)

    if email == schedule_owner_email do
      {:error, :email_cannot_be_the_same}
    else
      {:ok, params}
    end
  end

  defp dyte_integration(schedule_params) do
    Multi.new()
    |> Multi.run(:create_schedule, fn repo, _ ->
      case create_schedule(schedule_params, repo) do
        {:ok, schedule} ->
          {:ok, repo.preload(schedule, :created_by)}

        errors ->
          errors
      end
    end)
    |> Multi.run(:create_meeting, fn repo, %{create_schedule: schedule} ->
      Todo.Operations.Meeting.create_dyte_meeting(schedule, repo)
    end)
    |> Multi.run(:meeting_owner, fn repo, %{create_meeting: meeting, create_schedule: schedule} ->
      Todo.Operations.Participant.create_dyte_participant(
        %{
          created_by_id: schedule.created_by_id,
          email: schedule.created_by.email,
          meeting_id: meeting.meeting_id,
          participant_name: "#{schedule.created_by.first_name} #{schedule.created_by.last_name}",
          preset_name: "basic-version-1"
        },
        repo
      )
    end)
    |> Multi.run(:participant, fn repo, %{create_meeting: meeting, create_schedule: schedule} ->
      Todo.Operations.Participant.create_dyte_participant(
        %{
          created_by_id: schedule.created_by_id,
          email: schedule.email,
          meeting_id: meeting.meeting_id,
          participant_name: schedule.name,
          preset_name: "basic-version-1"
        },
        repo
      )
    end)
    |> Todo.Repo.transaction()
  end

  defp dyte_integration_module(), do: Application.fetch_env!(:todo, :api_modules)[:dyte]
end

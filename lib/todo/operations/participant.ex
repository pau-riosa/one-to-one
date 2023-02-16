defmodule Todo.Operations.Participant do
  @moduledoc false
  alias Todo.Schemas.Participant, as: Schema
  alias Todo.Repo
  require Logger

  def changeset(struct \\ %Schema{}, params \\ %{}) do
    Schema.changeset(struct, params)
  end

  def create(params, repo \\ Repo) do
    %Schema{}
    |> changeset(params)
    |> repo.insert()
  end

  def update(%Schema{} = struct, params) do
    struct
    |> changeset(params)
    |> Repo.update()
  end

  def delete(%Schema{} = struct) do
    Repo.delete(struct)
  end

  def create_dyte_participant(
        %{
          schedule: schedule,
          email: email,
          meeting_id: meeting_id,
          participant_name: participant_name,
          preset_name: preset_name
        },
        repo \\ Repo
      ) do
    case dyte_integration_module().create_participant(meeting_id, participant_name, preset_name) do
      {:ok, %{"data" => data}} ->
        %{
          meeting_id: meeting_id,
          token: data["authResponse"]["authToken"],
          participant_id: data["authResponse"]["id"],
          created_by_id: schedule.created_by_id,
          email: email
        }
        |> create(repo)

      errors ->
        Logger.warning("[Operations.Participant] #{inspect(errors)}")
        {:error, :cannot_create_participant}
    end
  end

  defp dyte_integration_module(), do: Application.fetch_env!(:todo, :api_modules)[:dyte]
end

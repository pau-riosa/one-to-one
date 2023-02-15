defmodule Todo.Operations.Meeting do
  @moduledoc false
  alias Todo.Schemas.Meeting, as: Schema
  alias Todo.Repo

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

  def create_dyte_meeting(schedule, repo \\ Repo, title \\ "Welcome to your 1 to 1 session") do
    case dyte_integration_module.create_meeting(title) do
      {:ok, %{"data" => data}} ->
        %{
          meeting_id: data["meeting"]["id"],
          room_name: data["meeting"]["roomName"],
          status: data["meeting"]["status"],
          title: data["meeting"]["title"],
          schedule_id: schedule.id,
          created_by_id: schedule.created_by_id
        }
        |> create(repo)

      _ ->
        {:error, :cannot_create_meeting}
    end
  end

  defp dyte_integration_module(), do: Application.fetch_env!(:todo, :api_modules)[:dyte]
end

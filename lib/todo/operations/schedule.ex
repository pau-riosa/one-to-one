defmodule Todo.Operations.Schedule do
  @moduledoc false
  alias Todo.Schemas.Schedule, as: Schema
  alias Todo.Repo

  def changeset(struct \\ %Schema{}, params \\ %{}) do
    Schema.changeset(struct, params)
  end

  def create(params, repo \\ Repo) do
    %Schema{}
    |> Schema.set_schedule_changeset(params)
    |> repo.insert()
  end

  def create_schedule(params, repo \\ Repo) do
    %Schema{}
    |> Schema.changeset(params)
    |> Map.put(:action, :insert)
    |> repo.insert()
  end
end

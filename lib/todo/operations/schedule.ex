defmodule Todo.Operations.Schedule do
  @moduledoc false
  alias Todo.Schemas.Schedule, as: Schema
  alias Todo.Repo

  def changeset(struct \\ %Schema{}, params \\ %{}) do
    Schema.changeset(struct, params)
  end

  def create(params) do
    %Schema{}
    |> Schema.set_schedule_changeset(params)
    |> Repo.insert()
  end
end

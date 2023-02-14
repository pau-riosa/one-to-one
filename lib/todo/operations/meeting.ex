defmodule Todo.Operations.Meeting do
  @moduledoc false
  alias Todo.Schemas.Meeting, as: Schema
  alias Todo.Repo

  def changeset(struct \\ %Schema{}, params \\ %{}) do
    Schema.changeset(struct, params)
  end

  def create(params) do
    %Schema{}
    |> changeset(params)
    |> Repo.insert()
  end

  def update(%Schema{} = struct, params) do
    struct
    |> changeset(params)
    |> Repo.update()
  end

  def delete(%Schema{} = struct) do
    Repo.delete(struct)
  end
end

defmodule Todo.Schedules.Operation do
  @moduledoc """
  Operations for Event
  """
  alias Ecto.Multi
  alias Todo.{Repo, Schedules.Schedule}

  def call(changesets) when is_list(changesets) do
    changesets
    |> Enum.reduce(Multi.new(), fn changeset, multi ->
      Multi.insert(multi, {:schedule, changeset.changes.scheduled_for}, changeset)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        {:ok, :ok}

      {:error, {:schedule, _}, changeset, _} ->
        {:error, changeset}
    end
  end
end

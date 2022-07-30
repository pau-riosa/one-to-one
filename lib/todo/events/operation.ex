defmodule Todo.Events.Operation do
  @moduledoc """
  Operations for Event
  """
  alias Ecto.Multi
  alias Todo.Repo

  def call(changeset) do
    Multi.new()
    |> Multi.insert(:create_event, changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{create_event: event}} ->
        {:ok, event}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end
end

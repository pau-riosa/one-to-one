defmodule Todo.Events.Operation do
  @moduledoc """
  Operations for Event
  """
  alias Todo.Events.Event
  alias Ecto.Multi
  alias Todo.Repo

  @spec update(Event.t(), Map.t()) :: {:ok, Map.t()} | {:error, Ecto.Changeset.t()}
  def update(%Event{} = event, params) do
    changeset = Event.changeset(event, params)

    Multi.new()
    |> Multi.update(:update_event, changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{update_event: event}} ->
        {:ok, event}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def insert(%Event{} = event, params) do
    changeset = Event.changeset(event, params)

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

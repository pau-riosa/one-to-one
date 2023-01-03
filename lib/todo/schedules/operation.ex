defmodule Todo.Schedules.Operation do
  @moduledoc """
  Operations for Event
  """
  alias Ecto.Multi
  alias Todo.Repo
  alias Todo.Schedules.Schedule

  @doc """
  Accepts a list of Datetime and create a schedule
  """
  @spec call(List.t(), Map.t()) :: {:ok, :ok} | {:error, any()}
  def call(timeslots, params) when is_list(timeslots) do
    timeslots
    |> Enum.map(fn timeslot ->
      params = Map.put(params, "scheduled_for", timeslot)
      Schedule.changeset(%Schedule{}, params)
    end)
    |> Enum.reduce(Multi.new(), fn changeset, multi ->
      Multi.insert(multi, {:schedule, changeset.changes.scheduled_for}, changeset)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        TodoWeb.Endpoint.broadcast("events", "new_event", %{
          event_id: params["event_id"]
        })

        {:ok, :ok}

      {:error, {:schedule, _}, changeset, _} ->
        {:error, changeset}
    end
  end

  def create_schedule(changeset, attrs) do
    Schedule.set_schedule_changeset(changeset, attrs)
    |> Repo.insert()
  end
end

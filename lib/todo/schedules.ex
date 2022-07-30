defmodule Todo.Schedules do
  @moduledoc """
  The Schedules context
  """
  import Ecto.Query
  alias Todo.Schedules.Schedule
  alias Todo.Repo

  def get_all_schedules(created_by_id) do
    Schedule
    |> join(:left, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.created_by_id == ^created_by_id)
    |> select([s], s.scheduled_for)
    |> Repo.all()
  end

  def get_schedules_by_event_ids(event_ids) when is_list(event_ids) do
    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.id in ^event_ids)
    |> order_by([s], desc: s.scheduled_for)
    |> Repo.all()
  end

  def get_schedules_by_event_id(event_id) when is_binary(event_id) do
    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.id == ^event_id)
    |> order_by([s], desc: s.scheduled_for)
    |> Repo.all()
  end

  def get_schedules_by_created_by_id(created_by_id) when is_binary(created_by_id) do
    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.created_by_id == ^created_by_id)
    |> select([s, event: e], %{
      event: e,
      scheduled_for: s.scheduled_for
    })
    |> order_by([s], desc: s.scheduled_for)
    |> Repo.all()
  end
end

defmodule Todo.Schedules do
  @moduledoc """
  The Schedules context
  """
  import Ecto.Query
  alias Timex
  alias Todo.Schedules.Schedule
  alias Todo.Repo

  def get_all_past_schedules(created_by_id) do
    Schedule
    |> join(:left, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.created_by_id == ^created_by_id)
    |> where([s], s.scheduled_for < ^Timex.now())
    |> select([s, event: e], %{
      event: e,
      scheduled_for: s.scheduled_for
    })
    |> Repo.all()
  end

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

  def get_schedules_by_created_by_id(created_by_id, current_date \\ Timex.now())
      when is_binary(created_by_id) do
    beginning_of_day = Timex.beginning_of_day(current_date)
    end_of_day = Timex.end_of_day(current_date)

    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.created_by_id == ^created_by_id)
    |> where([s], fragment("? BETWEEN ? AND ?", s.scheduled_for, ^beginning_of_day, ^end_of_day))
    |> select([s, event: e], %{
      event: e,
      scheduled_for: s.scheduled_for
    })
    |> order_by([s], desc: s.scheduled_for)
    |> Repo.all()
  end
end

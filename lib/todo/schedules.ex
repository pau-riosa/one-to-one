defmodule Todo.Schedules do
  @moduledoc """
  The Schedules context
  """
  import Ecto.Query
  alias Todo.Schedules.Schedule
  alias Todo.Repo

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

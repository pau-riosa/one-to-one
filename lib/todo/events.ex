defmodule Todo.Events do
  @moduledoc """
  The Events context
  """
  import Ecto.Query
  alias Todo.Events.Event
  alias Todo.Repo

  def get_events_id(event_id) when is_binary(event_id) do
    Event
    |> where([e], e.id == ^event_id)
    |> Repo.all()
  end

  def get_events_by_created_by_id(created_by_id) when is_binary(created_by_id) do
    Event
    |> where([e], e.created_by_id == ^created_by_id)
    |> Repo.all()
  end
end

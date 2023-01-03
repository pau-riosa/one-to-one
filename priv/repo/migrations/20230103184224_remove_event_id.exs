defmodule Todo.Repo.Migrations.RemoveEventId do
  use Ecto.Migration

  alias Todo.Schedules.Schedule
  import Ecto.Query
  alias Todo.Repo

  def change do
    from(s in Schedule)
    |> Repo.update_all(set: [event_id: nil])

    alter table(:schedules) do
      remove :event_id
    end
  end
end

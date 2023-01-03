defmodule Todo.Repo.Migrations.RemoveEventId do
  use Ecto.Migration

  alias Todo.Schedules.Schedule
  import Ecto.Query
  alias Todo.Repo

  def change do
    alter table(:schedules) do
      remove :event_id
    end
  end
end

defmodule Todo.Repo.Migrations.AddUniqueIndexForEmailTokenAndMeeting do
  use Ecto.Migration

  @disable_migration_lock true
  @disable_ddl_transaction true

  alias Todo.Schemas.Participant
  alias Todo.Schemas.Meeting
  alias Todo.Schemas.Schedule
  import Ecto.Query

  def change do
    Schedule
    |> where([s], s.inserted_at < ^Timex.now())
    |> repo().delete_all()

    Participant
    |> where([s], s.inserted_at < ^Timex.now())
    |> repo().delete_all()

    Meeting
    |> where([s], s.inserted_at < ^Timex.now())
    |> repo().delete_all()

    create unique_index(:participants, [:email, :meeting_id])
  end
end

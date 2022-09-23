defmodule Todo.Repo.Migrations.AddDetailsToSchedule do
  use Ecto.Migration

  def change do
    alter table(:schedules) do
      add :start_at, :utc_datetime_usec
      add :end_at, :utc_datetime_usec
      add :name, :string
      add :email, :citext
      add :comment, :text
    end
  end
end

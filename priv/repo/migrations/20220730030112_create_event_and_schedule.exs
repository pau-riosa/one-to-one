defmodule Todo.Repo.Migrations.CreateEventAndSchedule do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :text
      add :description, :text
      add :created_by_id, references(:users, type: :binary_id), null: false

      timestamps()
    end

    create table(:schedules, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :duration, :integer
      add :scheduled_for, :utc_datetime_usec
      add :created_by_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :event_id, references(:events, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:schedules, [:created_by_id, :scheduled_for])
  end
end

defmodule Todo.Repo.Migrations.CreateMeetingAndParticipantSchemas do
  use Ecto.Migration

  alias Todo.Schedules.Schedule
  import Ecto.Query

  def change do
    create table(:meetings, primary_key: false) do
      add :meeting_id, :string, primary_key: true
      add :room_name, :string
      add :status, :string
      add :title, :string
      add :schedule_id, references(:schedules, type: :uuid, on_delete: :delete_all), null: false
      add :created_by_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:meetings, [:meeting_id])
    create unique_index(:meetings, [:room_name])

    create table(:participants, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :token, :text
      add :participant_id, :string
      add :email, :citext

      add :meeting_id,
          references(:meetings, column: :meeting_id, type: :string, on_delete: :delete_all)

      add :created_by_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:participants, [:token])
    create unique_index(:participants, [:meeting_id])

    alter table(:schedules) do
      add :meeting_id,
          references(:meetings, column: :meeting_id, type: :string, on_delete: :delete_all)
    end
  end
end

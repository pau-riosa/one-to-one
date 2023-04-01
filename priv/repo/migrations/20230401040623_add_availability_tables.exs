defmodule Todo.Repo.Migrations.AddAvailabilityTables do
  use Ecto.Migration

  def up do
    DayEnum.create_type()

    create table(:availability_days, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:day, :day, null: false)

      add(:user_id, references(:users, type: :binary_id), null: false)

      timestamps()
    end

    create table(:availability_hours, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:from, :time, null: false)
      add(:to, :time, null: false)

      add(:availability_entry_id, references(:availability_days, type: :binary_id), null: false)

      timestamps()
    end
  end

  def down do
    drop(table(:availability_days))
    drop(table(:availability_hours))

    DayEnum.drop_type()
  end
end

defmodule Todo.Repo.Migrations.AddAvailabilityTables do
  use Ecto.Migration

  def up do
    AvailabilityDayEnum.create_type()

    create table(:availability_entries, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:day, :day, null: false)

      add(:user_id, references(:users, type: :binary_id), null: false)

      timestamps()
    end

    create table(:hours, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:from, :time, null: false)
      add(:to, :time, null: false)

      add(:availability_entry_id, references(:availability_entries, type: :binary_id), null: false)

      timestamps()
    end
  end

  def down do
    drop(table(:availability_entries))
    drop(table(:hours))

    AvailabilityDayEnum.drop_type()
  end
end

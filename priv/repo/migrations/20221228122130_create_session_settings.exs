defmodule Todo.Repo.Migrations.CreateSessionSettings do
  use Ecto.Migration

  def change do
    create table(:session_settings, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:day, :string)
      add(:times, {:array, :map})
      add(:user_id, references(:users, type: :binary_id), null: false)
      timestamps()
    end
  end
end

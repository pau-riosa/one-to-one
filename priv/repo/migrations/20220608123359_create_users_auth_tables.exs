defmodule Todo.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext", "")

    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:email, :citext, null: false)
      add(:hashed_password, :string, null: false)
      add(:confirmed_at, :utc_datetime_usec)
      add(:first_name, :string)
      add(:last_name, :string)
      add(:middle_name, :string)
      add(:birthdate, :utc_datetime_usec)
      add(:avatar, :string)
      timestamps()
    end

    create(unique_index(:users, [:email]))

    create table(:users_tokens, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:token, :binary, null: false)
      add(:context, :string, null: false)
      add(:sent_to, :string)

      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
      timestamps(updated_at: false)
    end

    create(index(:users_tokens, [:user_id]))
    create(unique_index(:users_tokens, [:context, :token]))
  end
end

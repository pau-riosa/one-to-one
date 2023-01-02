defmodule Todo.Repo.Migrations.CreateDurationSlugOnUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :slug, :string, null: false, default: ""
      add :duration, :integer, null: false, default: 15
    end
  end
end

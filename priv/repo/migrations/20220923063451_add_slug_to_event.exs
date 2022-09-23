defmodule Todo.Repo.Migrations.AddSlugToEvent do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :slug, :string
    end
  end
end

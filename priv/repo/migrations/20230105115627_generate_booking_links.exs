defmodule Todo.Repo.Migrations.GenerateBookingLinks do
  use Ecto.Migration

  alias Todo.Schemas.User
  alias Todo.Repo

  import Ecto.Query

  def change do
    query =
      from(u in User,
        where: is_nil(u.slug)
      )

    Repo.update_all(query, set: [slug: Ecto.UUID.generate()])
  end
end

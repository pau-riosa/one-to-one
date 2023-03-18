defmodule Todo.Schemas.AvailabilityEntry do
  use Todo.Schema
  alias Todo.Schemas.{Hour, User}
  import Ecto.Changeset

  schema "availability_entries" do
    field :day, AvailabilityDayEnum

    belongs_to :user, User

    has_many :hours, Hour

    timestamps()
  end

  @required_attributes ~w(day user_id)a

  def changeset(schema, params) do
    schema
    |> cast(params, @required_attributes)
    |> validate_required(@required_attributes)
    |> cast_assoc(:hours)
  end
end

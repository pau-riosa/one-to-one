defmodule Todo.Schemas.AvailabilityDay do
  use Todo.Schema
  alias Todo.Schemas.{AvailabilityHour, User}
  import Ecto.Changeset

  schema "availability_entries" do
    field :day, DayEnum

    belongs_to :user, User

    has_many :hours, AvailabilityHour

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

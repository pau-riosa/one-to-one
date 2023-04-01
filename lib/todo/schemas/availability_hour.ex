defmodule Todo.Schemas.AvailabilityHour do
  use Todo.Schema
  alias Todo.Schemas.AvailabilityDay
  import Ecto.Changeset

  schema "hours" do
    field :from, :time
    field :to, :time

    belongs_to :availability_day, AvailabilityDay

    timestamps()
  end

  @required_attributes ~w(from to)a

  def changeset(schema, params) do
    schema
    |> cast(params, @required_attributes)
    |> validate_required(@required_attributes)
  end
end
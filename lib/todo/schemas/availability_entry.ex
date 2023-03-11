defmodule Todo.Schemas.AvailabilityEntry do
  use Todo.Schema
  alias Todo.Schemas.{Hour, User}

  schema "availability_entries" do
    field :day, AvailabilityDayEnum

    belongs_to :user, User

    has_many :hours, Hour

    timestamps()
  end
end

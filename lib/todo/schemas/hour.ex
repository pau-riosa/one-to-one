defmodule Todo.Schemas.Hour do
  use Todo.Schema
  alias Todo.Schemas.AvailabilityEntry

  schema "hours" do
    field :from, :time
    field :to, :time

    belongs_to :availability_entry, AvailabilityEntry

    timestamps()
  end
end

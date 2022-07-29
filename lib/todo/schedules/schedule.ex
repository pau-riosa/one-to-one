defmodule Todo.Schedules.Schedule do
  use Ecto.Schema
  import Ecto.Changeset

  schema "schedules" do
    field :scheduled_for, :utc_datetime_usec
    field :duration, :integer
    belongs_to(:event, Todo.Events.Event)

    timestamps()
  end

  @required_attrs [
    :scheduled_for,
    :event_id
  ]

  @optional_attrs [:duration]

  def changeset(event, attrs \\ %{}) do
    event
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
  end
end

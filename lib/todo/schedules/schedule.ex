defmodule Todo.Schedules.Schedule do
  use Todo.Schema

  schema "schedules" do
    field :scheduled_for, :utc_datetime_usec
    field :duration, :integer
    belongs_to(:event, Todo.Events.Event)
    belongs_to(:created_by, Todo.Accounts.User)

    timestamps()
  end

  @required_attrs [
    :scheduled_for,
    :event_id,
    :created_by_id
  ]

  @optional_attrs [:duration]

  def changeset(event, attrs \\ %{}) do
    event
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint([:created_by_id, :scheduled_for], message: "schedule already exist.")
  end
end

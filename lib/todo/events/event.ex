defmodule Todo.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :name, :string
    field :schedules, {:array, :string}, virtual: true
    field :description, :string
    belongs_to(:created_by, Todo.Accounts.User)
    timestamps()
  end

  @required_attrs [
    :name,
    :created_by_id,
    :schedules
  ]

  @optional_attrs [:description]

  def changeset(event, attrs \\ %{}) do
    event
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> check_timeslots()
  end

  def check_timeslots(%{changes: %{schedules: []}} = changeset),
    do: add_error(changeset, :schedules, "Kindly select a schedule/s")

  def check_timeslots(changeset), do: changeset
end

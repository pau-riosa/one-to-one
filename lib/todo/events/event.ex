defmodule Todo.Events.Event do
  use Todo.Schema

  schema "events" do
    field :name, :string
    field :description, :string
    belongs_to(:created_by, Todo.Accounts.User)
    timestamps()
  end

  @required_attrs [
    :name,
    :created_by_id
  ]

  @optional_attrs [:description]

  def changeset(event, attrs \\ %{}) do
    event
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
  end
end

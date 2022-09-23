defmodule Todo.Events.Event do
  use Todo.Schema

  schema "events" do
    field :name, :string
    field :description, :string
    field :files, {:array, :string}, default: []
    field :slug, :string
    belongs_to(:created_by, Todo.Accounts.User)
    timestamps()
  end

  @required_attrs [
    :name,
    :created_by_id
  ]

  @optional_attrs [:description, :files, :slug]

  def changeset(event, attrs \\ %{}) do
    event
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> add_slug(attrs)
  end

  def add_slug(changeset, %{"name" => name}) do
    put_change(changeset, :slug, Inflex.parameterize(name, "-"))
  end

  def add_slug(changeset, _), do: changeset
end

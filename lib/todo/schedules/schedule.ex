defmodule Todo.Schedules.Schedule do
  use Todo.Schema

  schema "schedules" do
    field :scheduled_for, :utc_datetime_usec
    field :duration, :integer
    field :name, :string
    field :email, :string
    field :comment, :string
    field :start_at, :utc_datetime_usec
    field :end_at, :utc_datetime_usec

    belongs_to(:created_by, Todo.Accounts.User)

    timestamps()
  end

  @required_attrs [
    :scheduled_for,
    :created_by_id
  ]

  @optional_attrs [:duration, :name, :email, :comment, :start_at, :end_at]

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint([:created_by_id, :scheduled_for], message: "schedule already exist.")
  end

  @set_schedule_attrs [
    :name,
    :email,
    :scheduled_for,
    :created_by_id,
    :duration
  ]

  @set_schedule_optional_attrs [
    :comment
  ]
  def set_schedule_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @set_schedule_attrs ++ @set_schedule_optional_attrs)
    |> validate_required(@set_schedule_attrs)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> unique_constraint([:created_by_id, :scheduled_for], message: "schedule already exist.")
  end
end

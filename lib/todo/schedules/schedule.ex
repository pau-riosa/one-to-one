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

    # fields to enable nested form
    field :day, :string, virtual: true

    embeds_many :times, Time, on_replace: :delete do
      field :start_time, :string
      field :end_time, :string
    end

    belongs_to(:event, Todo.Events.Event)
    belongs_to(:created_by, Todo.Accounts.User)

    timestamps()
  end

  @required_attrs [
    :scheduled_for,
    :event_id,
    :created_by_id
  ]

  @optional_attrs [:day, :duration, :name, :email, :comment, :start_at, :end_at]

  def changeset(event, attrs \\ %{}) do
    event
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint([:created_by_id, :scheduled_for], message: "schedule already exist.")
    |> cast_embed(:times, with: &time_changeset/2)
  end

  def time_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:start_time, :end_time])
    |> validate_required([:start_time, :end_time])
    |> check_time()
  end

  defp check_time(changeset) do
    start_time =
      changeset
      |> get_change(:start_time)
      |> Timex.parse!("%I:%M %p", :strftime)

    end_time =
      changeset
      |> get_change(:end_time)
      |> Timex.parse!("%I:%M %p", :strftime)

    if Timex.after?(start_time, end_time) do
      add_error(changeset, :start_time, "cannot be before end_time")
    else
      changeset
    end
  end

  @set_schedule_attrs [
    :name,
    :email
  ]

  @set_schedule_optional_attrs [
    :comment
  ]
  def set_schedule_changeset(event, attrs \\ %{}) do
    event
    |> cast(attrs, @set_schedule_attrs ++ @set_schedule_optional_attrs)
    |> validate_required(@set_schedule_attrs)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
  end
end

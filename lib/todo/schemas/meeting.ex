defmodule Todo.Schemas.Meeting do
  @moduledoc """
  Schema for saving Dyte.io meeting_data
  """
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]

  schema "meetings" do
    field :meeting_id, :string, primary_key: true
    field :room_name, :string
    field :status, :string
    field :title, :string
    belongs_to :schedule, Todo.Schemas.Schedule
    belongs_to :created_by, Todo.Accounts.User
    timestamps()
  end

  @required_attrs ~w(
    meeting_id
    room_name
    status
    title
    schedule_id
    created_by_id
  )a

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint([:meeting_id], message: "meeting_id already exist.")
    |> unique_constraint([:room_name], message: "room_name already exist.")
  end
end

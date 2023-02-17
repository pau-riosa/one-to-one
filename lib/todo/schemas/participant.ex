defmodule Todo.Schemas.Participant do
  @moduledoc """
  Schema for saving Dyte.io participant_data 
  """
  use Todo.Schema

  schema "participants" do
    field :token, :string
    field :participant_id, :string
    field :email, :string

    belongs_to :meeting, Todo.Schemas.Meeting, foreign_key: :meeting_id, type: :string
    belongs_to :created_by, Todo.Schemas.User
    timestamps()
  end

  @required_attrs ~w(
    token
    participant_id
    email
    meeting_id
    created_by_id
  )a

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint([:token, :meeting_id],
      message: "token cannot be duplicated or be reused for this meeting"
    )
    |> unique_constraint([:email, :meeting_id],
      message: "participant's email for this meeting already exists"
    )
  end
end

defmodule Todo.Time do
  use Todo.Schema

  @primary_key false
  embedded_schema do
    field :time_id, :string
    field :start_time, :string
    field :end_time, :string
  end

  def time_changeset(struct, attrs \\ %{}) do
    attrs = Map.put(attrs, "time_id", Ecto.UUID.generate())

    struct
    |> cast(attrs, [:time_id, :start_time, :end_time])
    |> check_time()
  end

  defp check_time(%{changes: %{start_time: start_time, end_time: end_time}} = changeset)
       when not (is_nil(start_time) and is_nil(end_time)) do
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

  defp check_time(changeset), do: changeset
end

defmodule Todo.SessionSetting do
  use Todo.Schema

  schema "session_settings" do
    field :day, :string

    belongs_to(:user, Todo.Accounts.User)
    timestamps()

    embeds_many :times, Todo.Time, on_replace: :delete
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:day, :user_id])
    |> cast_embed(:times, with: &Todo.Time.time_changeset/2)
  end
end

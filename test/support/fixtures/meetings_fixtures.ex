defmodule Todo.MeetingsFixtures do
  alias Todo.AccountsFixtures
  alias Todo.SchedulesFixtures

  def unique_email, do: "user#{System.unique_integer()}@example.com"

  def valid_schedule_attrs(attrs \\ %{}) do
    schedule = SchedulesFixtures.schedule_fixture()

    Enum.into(attrs, %{
      meeting_id: Ecto.UUID.generate(),
      room_name: Ecto.UUID.generate(),
      status: "true",
      title: "Meeting",
      schedule_id: schedule.id,
      created_by_id: schedule.created_by_id
    })
  end

  def meeting_fixture(attrs \\ %{}) do
    {:ok, meeting} =
      attrs
      |> valid_schedule_attrs()
      |> Todo.Operations.Meeting.create()

    meeting
  end
end

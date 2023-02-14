defmodule Todo.Operations.MeetingTest do
  use Todo.DataCase
  alias Todo.SchedulesFixtures
  alias Todo.MeetingsFixtures
  alias Todo.Operations.Meeting, as: Operation

  setup [:schedule_fixture, :meeting_fixture]

  test "create meeting", %{schedule: schedule} do
    params = %{
      meeting_id: Ecto.UUID.generate(),
      room_name: "hello-world",
      status: "true",
      title: "Meeting",
      schedule_id: schedule.id,
      created_by_id: schedule.created_by_id
    }

    assert {:ok, meeting} = Operation.create(params)
    assert meeting.meeting_id == params.meeting_id
    assert meeting.room_name == params.room_name
    assert meeting.status == params.status
    assert meeting.schedule_id == params.schedule_id
    assert meeting.created_by_id == params.created_by_id
  end

  test "update meeting", %{schedule: schedule, meeting: meeting} do
    params = %{
      meeting_id: Ecto.UUID.generate(),
      room_name: "hello-world",
      status: "true",
      title: "Meeting",
      schedule_id: schedule.id,
      created_by_id: schedule.created_by_id
    }

    assert {:ok, meeting} = Operation.update(meeting, params)
    assert meeting.meeting_id == params.meeting_id
    assert meeting.room_name == params.room_name
    assert meeting.status == params.status
    assert meeting.schedule_id == params.schedule_id
    assert meeting.created_by_id == params.created_by_id
  end

  test "delete meeting", %{meeting: meeting} do
    assert {:ok, meeting} = Operation.delete(meeting)
    assert is_nil(Repo.get(Todo.Schemas.Meeting, meeting.meeting_id))
  end

  def meeting_fixture(_) do
    %{meeting: MeetingsFixtures.meeting_fixture()}
  end

  def schedule_fixture(_) do
    %{schedule: SchedulesFixtures.schedule_fixture()}
  end
end

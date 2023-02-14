defmodule Todo.ParticipantsFixtures do
  alias Todo.MeetingsFixtures

  def unique_email, do: "user#{System.unique_integer()}@example.com"

  def valid_schedule_attrs(attrs \\ %{}) do
    meeting = MeetingsFixtures.meeting_fixture()

    Enum.into(attrs, %{
      token: Ecto.UUID.generate(),
      email: unique_email(),
      participant_id: Ecto.UUID.generate(),
      meeting_id: meeting.meeting_id,
      created_by_id: meeting.created_by_id
    })
  end

  def participant_fixture(attrs \\ %{}) do
    {:ok, participant} =
      attrs
      |> valid_schedule_attrs()
      |> Todo.Operations.Participant.create()

    participant
  end
end

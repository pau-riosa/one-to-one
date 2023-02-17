defmodule Todo.Operations.ParticipantTest do
  use Todo.DataCase
  alias Todo.ParticipantsFixtures
  alias Todo.MeetingsFixtures
  alias Todo.Operations.Participant, as: Operation

  setup [:meeting_fixture, :participant_fixture]

  test "check for duplicate emails", %{meeting: meeting} do
    params = %{
      token: Ecto.UUID.generate(),
      email: "user1@example.com",
      participant_id: Ecto.UUID.generate(),
      meeting_id: meeting.meeting_id,
      created_by_id: meeting.created_by_id
    }

    _existing_participant = ParticipantsFixtures.participant_fixture(params)

    params =
      params
      |> Map.put(:token, "other-token")

    assert {:ok, participant} = Operation.create(params)
    assert participant.meeting_id == params.meeting_id
    assert participant.token == params.token
    assert participant.email == params.email
    assert participant.participant_id == params.participant_id
    assert participant.created_by_id == params.created_by_id

    raise Todo.Repo.get_by(Todo.Schemas.Participant,
            email: params.email,
            meeting_id: params.meeting_id
          )
  end

  test "create participant", %{meeting: meeting} do
    params = %{
      token: Ecto.UUID.generate(),
      email: "user1@example.com",
      participant_id: Ecto.UUID.generate(),
      meeting_id: meeting.meeting_id,
      created_by_id: meeting.created_by_id
    }

    assert {:ok, participant} = Operation.create(params)
    assert participant.meeting_id == params.meeting_id
    assert participant.token == params.token
    assert participant.email == params.email
    assert participant.participant_id == params.participant_id
    assert participant.created_by_id == params.created_by_id
  end

  test "update participant", %{participant: participant, meeting: meeting} do
    params = %{
      token: Ecto.UUID.generate(),
      email: "user2@example.com",
      participant_id: Ecto.UUID.generate(),
      meeting_id: meeting.meeting_id,
      created_by_id: meeting.created_by_id
    }

    assert {:ok, participant} = Operation.update(participant, params)
    assert participant.meeting_id == params.meeting_id
    assert participant.token == params.token
    assert participant.email == params.email
    assert participant.participant_id == params.participant_id
    assert participant.created_by_id == params.created_by_id
  end

  test "delete participant", %{participant: participant} do
    assert {:ok, participant} = Operation.delete(participant)
    assert is_nil(Repo.get(Todo.Schemas.Participant, participant.id))
  end

  def meeting_fixture(_) do
    %{meeting: MeetingsFixtures.meeting_fixture()}
  end

  def participant_fixture(_) do
    %{participant: ParticipantsFixtures.participant_fixture()}
  end
end

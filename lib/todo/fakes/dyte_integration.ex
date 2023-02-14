defmodule Todo.Fakes.DyteIntegration do
  use Todo.TestFake

  def create_meeting(args) do
    add_request({:create_meeting, args})
    pop_response()
  end

  def create_participant(meeting_id, participant_name, preset_name) do
    add_request({:create_participant})
    pop_response()
  end
end

defmodule TodoWeb.MeetingChannel do
  use TodoWeb, :channel
  alias Todo.Repo
  alias Todo.Schemas.Participant
  alias Todo.Schemas.Meeting

  @impl Phoenix.Channel
  def join("meeting:" <> meeting_id, %{"participant_id" => participant_id} = _params, socket) do
    participant = Repo.get_by(Participant, participant_id: participant_id)
    meeting = Repo.get(Meeting, meeting_id)
    send(self(), {:after_join, %{authToken: participant.token, roomName: meeting.room_name}})
    {:ok, socket}
  end

  def join(_meeting_id, _params, socket) do
    {:ok, socket}
  end

  @impl Phoenix.Channel
  def handle_info({:after_join, payload}, socket) do
    # push only to the specific client for the current channel process
    push(socket, "after_join", payload)
    {:noreply, socket}
  end
end

defmodule Todo.Fakes.DyteIntegration do
  use Todo.TestFake
  alias __MODULE__

  def initialize() do
    DyteIntegration.init()

    DyteIntegration.add_response(
      {:ok,
       %{
         "data" => %{
           "meeting" => %{
             "createdAt" => "2023-02-14T02:33:13.982Z",
             "id" => Ecto.UUID.generate(),
             "liveStreamOnStart" => false,
             "participants" => [],
             "recordOnStart" => false,
             "roomName" => random_string(10),
             "status" => "LIVE",
             "title" => "Meeting with Juan"
           }
         },
         "message" => "",
         "success" => true
       }}
    )

    DyteIntegration.add_response(
      {:ok,
       %{
         "data" => %{
           "authResponse" => %{
             "authToken" => random_string(20),
             "id" => Ecto.UUID.generate(),
             "userAdded" => true
           }
         },
         "message" => "",
         "success" => true
       }}
    )

    DyteIntegration.add_response(
      {:ok,
       %{
         "data" => %{
           "authResponse" => %{
             "authToken" => random_string(20),
             "id" => Ecto.UUID.generate(),
             "userAdded" => true
           }
         },
         "message" => "",
         "success" => true
       }}
    )
  end

  def create_meeting(args) do
    add_request({:create_meeting, args})
    pop_response()
  end

  def create_participant(_meeting_id, _participant_name, _preset_name) do
    add_request({:create_participant})
    pop_response()
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end

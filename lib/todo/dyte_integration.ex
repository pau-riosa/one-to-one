defmodule Todo.DyteIntegration do
  @moduledoc """
    Dyte Api V1 integration
  """
  require Logger

  @base_url "https://api.cluster.dyte.in/v1"
  @presetName "basic-version-1"

  defp organization_id(), do: Application.fetch_env!(:todo, :dyte)[:org_id]
  defp api_key(), do: Application.fetch_env!(:todo, :dyte)[:api_key]

  def create_meeting(meeting_title \\ "Meeting") do
    url = Enum.join([@base_url, "/organizations/#{organization_id()}", "/meeting"], "")

    headers = [{"Authorization", api_key()}, {"Content-Type", "application/json"}]

    body =
      %{
        "title" => meeting_title,
        "presetName" => @presetName,
        "authorization" => %{
          "waitingRoom" => false,
          "closed" => false
        },
        "recordOnStart" => false,
        "liveStreamOnStart" => false
      }
      |> Jason.encode!()

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        Logger.info("[DyteIntegration] meeting created")
        Jason.decode(body)

      _ ->
        Logger.error("[DyteIntegration] meeting_not_created")
        :meeting_not_created
    end
  end

  def create_participant(%{meeting_id: nil}), do: :participant_not_created

  def create_participant(meeting_id, participant_name, preset_name \\ "basic-version-1") do
    url =
      [
        @base_url,
        "/organizations/#{organization_id()}",
        "/meetings",
        "/#{meeting_id}",
        "/participant"
      ]
      |> Enum.join("")

    headers = [{"Authorization", api_key()}, {"Content-Type", "application/json"}]

    body =
      %{
        "clientSpecificId" => Ecto.UUID.generate(),
        "userDetails" => %{
          "name" => participant_name
        },
        "presetName" => preset_name
      }
      |> Jason.encode!()

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        Logger.info("[DyteIntegration] participant created")
        Jason.decode(body)

      _ ->
        Logger.error("[DyteIntegration] participant_not_created")
        :participant_not_created
    end
  end
end

defmodule Todo.DyteIntegration do
  @moduledoc """
    Dyte Api V1 integration
  """
  require Logger

  @base_url "https://api.cluster.dyte.in/v1"
  @organization_id Application.get_env(:todo, :org_id)
  @api_key Application.get_env(:todo, :api_key)

  @doc """
  meeting_title
  """
  def create_meeting(meeting_title \\ "Meeting") do
    url =
      [@base_url, "/organizations/#{@organization_id}", "/meeting"]
      |> Enum.join("")

    headers = [{"Authorization", @api_key}, {"Content-Type", "application/json"}]

    body =
      %{
        "title" => meeting_title,
        "presetName" => "basic-version-1",
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

  @doc """
  meeting_id
  participant_name
  preset_name

  """
  def create_participant(meeting_id, participant_name, preset_name) do
    url =
      [
        @base_url,
        "/organizations/#{@organization_id}",
        "/meetings",
        "/#{meeting_id}",
        "/participant"
      ]
      |> Enum.join("")

    headers = [{"Authorization", @api_key}, {"Content-Type", "application/json"}]

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

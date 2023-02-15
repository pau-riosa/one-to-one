defmodule TodoWeb.Components.CreateSessionTest do
  @moduledoc """
    CreateSession Modal LiveComponent Test
  """
  use TodoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Ecto.Query
  import Swoosh.TestAssertions

  alias TodoWeb.Components.CreateSession
  alias Todo.Schemas.Schedule
  alias Todo.Schemas.Participant
  alias Todo.Schemas.Meeting
  alias Todo.Repo
  alias Swoosh.Email
  alias Todo.Fakes.DyteIntegration

  setup %{conn: conn}, do: register_and_log_in_user(%{conn: conn})

  test "render component", %{user: user} do
    assert render_component(CreateSession, id: 123, timezone: "Asia/Manila", current_user: user) =~
             "<div>\n  <div id=\"create-session\">\n\n</div>\n    </div>"
  end

  describe "create-session modal" do
    setup do
      DyteIntegration.init()

      DyteIntegration.add_response(
        {:ok,
         %{
           "data" => %{
             "meeting" => %{
               "createdAt" => "2023-02-14T02:33:13.982Z",
               "id" => "4cbb10b3-cc1e-4ce8-9f0b-17ea6af63f70",
               "liveStreamOnStart" => false,
               "participants" => [],
               "recordOnStart" => false,
               "roomName" => "jtdilh-marnpv",
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
               "authToken" => "authToken",
               "id" => "26329cc3-55d6-4c9f-8c99-feedde77991e",
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
               "authToken" => "authToken-participant-2",
               "id" => Ecto.UUID.generate(),
               "userAdded" => true
             }
           },
           "message" => "",
           "success" => true
         }}
      )
    end

    test "should create schedule", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/users/dashboard")

      assert view
             |> element("button#button-create-session")
             |> render_click() =~ "Set up 1 to 1 session"

      assert view
             |> element("form")
             |> render_submit(%{
               schedule: %{
                 email: "sample@example.com",
                 name: "name",
                 comment: "comment",
                 created_by_id: user.id,
                 duration: 15,
                 timezone: "Asia/Manila",
                 date: "2023-12-31",
                 time: "12:00 AM"
               }
             })

      assert schedules = Repo.all(Schedule)
      assert Enum.count(schedules) == 1
      assert schedule = schedules |> hd
      assert %Schedule{} = schedule
    end

    test "should send schedule email instructions", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/users/dashboard")

      assert view
             |> element("button#button-create-session")
             |> render_click() =~ "Set up 1 to 1 session"

      assert view
             |> element("form")
             |> render_submit(%{
               schedule: %{
                 email: "sample@example.com",
                 name: "name",
                 comment: "comment",
                 created_by_id: user.id,
                 duration: 15,
                 timezone: "Asia/Manila",
                 date: "2023-12-31",
                 time: "12:00 AM"
               }
             })

      assert schedule = Schedule |> preload(:created_by) |> Repo.all() |> hd

      assert_email_sent(
        subject:
          "Upcoming Appointment with: #{schedule.created_by.first_name} #{schedule.created_by.last_name}"
      )
    end

    test "should create 1 dyte meeting w/ 2 participants only", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/users/dashboard")

      assert view
             |> element("button#button-create-session")
             |> render_click() =~ "Set up 1 to 1 session"

      assert view
             |> element("form")
             |> render_submit(%{
               schedule: %{
                 email: "sample@example.com",
                 name: "name",
                 comment: "comment",
                 created_by_id: user.id,
                 duration: 15,
                 timezone: "Asia/Manila",
                 date: "2023-12-31",
                 time: "12:00 AM"
               }
             })

      assert Enum.count(Repo.all(Meeting)) == 1
      assert Enum.count(Repo.all(Participant)) == 2
    end
  end
end

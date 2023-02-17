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
  alias Todo.Fakes.DyteIntegration

  setup %{conn: conn}, do: register_and_log_in_user(%{conn: conn})

  test "render component", %{user: user} do
    assert render_component(CreateSession,
             id: 123,
             timezone: "Asia/Manila",
             current_user: user,
             active_url: "/users/dashboard"
           ) =~
             "<div>\n  <div id=\"create-session\">\n\n</div>\n    </div>"
  end

  describe "create-session modal" do
    setup do
      DyteIntegration.initialize()
    end

    test "should not create schedule, if duplicate participant email found", %{conn: conn} do
      user = Todo.AccountsFixtures.user_fixture(%{email: "sample@example.com"})
      conn = log_in_user(conn, user)

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
      assert Enum.count(schedules) == 0
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

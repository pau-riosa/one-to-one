defmodule TodoWeb.RoomController do
  use TodoWeb, :controller
  alias Todo.Repo
  alias Todo.Schemas.User
  alias Todo.Schemas.Schedule

  @room_name "cmhuqc-aedepy"
  @auth_token "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImZmY2ViNjg5LWU3OGMtNGFkMi1hMTdkLTY4MWNiYzAyM2E0MyIsImxvZ2dlZEluIjp0cnVlLCJpYXQiOjE2NzU5MjY2OTEsImV4cCI6MTY4NDU2NjY5MX0.GToJS1ZTO2Fwv1MRuCu7ehfAJr2AF0M9JHBzrkd9W---OyKBWBYeS6himqpZRAiK1ybCN6HeyMeiD4NdrTteX_k5uyFjqQnX935FakbsuwHqCCoPuUxKmv2Vgj8kd0j8mzgRrEhw1tfgfGQKrYxZGYn_LeSf_CT3PmnYR5U9p_P5L-lZBPessY0ebpisLa4OZHkkIPgVHyz0yx1XyY-neVpzwC0zvtCccVxVKJuB14Qz35pGK3GcPbw07gNpkwk5lAKKYdTZiL-Bhx20QmM-qJDJbGoK9mNhotmP-5YT0WCaitKkVEY1JXfZG3lnnu7OAOJGfk75hhao6xkxWMHYPw"
  @org_id Application.get_env(:todo, :org_id)

  def index(
        %{assigns: %{current_user: %User{} = current_user}} = conn,
        %{"schedule_id" => schedule_id} = _params
      ) do
    schedule =
      Schedule
      |> Repo.get(schedule_id)
      |> Repo.preload(:created_by)

    email = current_user.email

    render(conn, "index.html",
      schedule_id: schedule_id,
      schedule: schedule,
      email: email,
      org_id: @org_id,
      auth_token: @auth_token,
      room_name: @room_name
    )
  end

  def index(%{assigns: %{email: email}} = conn, %{"schedule_id" => schedule_id} = _params) do
    schedule =
      Schedule
      |> Repo.get(schedule_id)
      |> Repo.preload(:created_by)

    render(conn, "index.html",
      schedule_id: schedule_id,
      schedule: schedule,
      email: email,
      org_id: @org_id,
      auth_token: @auth_token,
      room_name: @room_name
    )
  end

  def index(conn, %{"schedule_id" => schedule_id} = _params) do
    changeset = Schedule.changeset(%Schedule{})

    schedule =
      Schedule
      |> Repo.get(schedule_id)
      |> Repo.preload(:created_by)

    render(conn, "room_details.html",
      changeset: changeset,
      schedule_id: schedule_id,
      schedule: schedule
    )
  end

  def enter(conn, %{"schedule" => schedule_params, "schedule_id" => schedule_id} = params) do
    schedule =
      Schedule
      |> Repo.get_by(id: schedule_id, email: schedule_params["email"])

    schedule
    |> case do
      %Schedule{} = schedule ->
        schedule =
          schedule
          |> Repo.preload(:created_by)

        conn
        |> put_flash(:info, "Welcome")
        |> assign(:email, schedule.email)
        |> render("index.html",
          schedule_id: schedule_id,
          schedule: schedule,
          email: schedule.email
        )

      _ ->
        changeset = Schedule.changeset(%Schedule{})

        conn
        |> put_flash(:error, "No participant found.")
        |> render("room_details.html",
          changeset: changeset,
          schedule_id: schedule_id
        )
    end
  end
end

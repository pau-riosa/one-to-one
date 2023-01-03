defmodule TodoWeb.RoomController do
  use TodoWeb, :controller
  alias Todo.Repo
  alias Todo.Accounts.User
  alias Todo.Schedules.Schedule

  def index(
        %{assigns: %{current_user: %User{} = current_user}} = conn,
        %{"schedule_id" => schedule_id} = _params
      ) do
    schedule =
      Schedule
      |> Repo.get(schedule_id)
      |> Repo.preload(:created_by)

    email = current_user.email
    render(conn, "index.html", schedule_id: schedule_id, schedule: schedule, email: email)
  end

  def index(%{assigns: %{email: email}} = conn, %{"schedule_id" => schedule_id} = _params) do
    schedule =
      Schedule
      |> Repo.get(schedule_id)
      |> Repo.preload(:created_by)

    render(conn, "index.html", schedule_id: schedule_id, schedule: schedule, email: email)
  end

  def index(conn, %{"schedule_id" => schedule_id} = _params) do
    changeset = Schedule.changeset(%Schedule{})
    render(conn, "room_details.html", changeset: changeset, schedule_id: schedule_id)
  end

  def enter(conn, %{"schedule" => schedule, "schedule_id" => schedule_id} = params) do
    Schedule
    |> Repo.get_by(id: schedule_id, email: schedule["email"])
    |> Repo.preload(:created_by)
    |> case do
      %Schedule{} = schedule ->
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
        |> render("room_details.html", changeset: changeset, schedule_id: schedule_id)
    end
  end
end

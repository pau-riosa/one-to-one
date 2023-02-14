defmodule TodoWeb.RoomController do
  use TodoWeb, :controller
  alias Todo.Repo
  alias Todo.Schemas.User
  alias Todo.Schemas.Schedule

  @org_id Application.get_env(:todo, :org_id)

  def index(
        %{assigns: %{current_user: %User{} = current_user}} = conn,
        %{
          "schedule_id" => schedule_id,
          "participant_id" => participant_id,
          "meeting_id" => meeting_id
        } = _params
      ) do
    schedule =
      Schedule
      |> Repo.get(schedule_id)
      |> Repo.preload(:created_by)

    participant =
      Todo.Schemas.Participant
      |> Repo.get_by(participant_id: participant_id)

    meeting =
      Todo.Schemas.Meeting
      |> Repo.get(meeting_id)

    render(conn, "index.html",
      schedule_id: schedule_id,
      schedule: schedule,
      org_id: @org_id,
      auth_token: participant.token,
      room_name: meeting.room_name
    )
  end

  def index(
        conn,
        %{
          "schedule_id" => schedule_id,
          "participant_id" => participant_id,
          "meeting_id" => meeting_id
        } = _params
      ) do
    schedule =
      Schedule
      |> Repo.get(schedule_id)
      |> Repo.preload(:created_by)

    participant =
      Todo.Schemas.Participant
      |> Repo.get_by(participant_id: participant_id)

    meeting =
      Todo.Schemas.Meeting
      |> Repo.get(meeting_id)

    render(conn, "index.html",
      schedule_id: schedule_id,
      schedule: schedule,
      org_id: @org_id,
      auth_token: participant.token,
      room_name: meeting.room_name
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

defmodule TodoWeb.RoomController do
  use TodoWeb, :controller
  alias Todo.Repo

  def index(conn, %{"schedule_id" => schedule_id} = _params) do
    schedule =
      Todo.Schedules.Schedule
      |> Repo.get(schedule_id)
      |> Repo.preload(:event)

    render(conn, "index.html", schedule_id: schedule_id, schedule: schedule)
  end
end

defmodule TodoWeb.RoomController do
  use TodoWeb, :controller

  def index(conn, %{"event_id" => event_id} = _params) do
    event = Todo.Repo.get(Todo.Events.Event, event_id)
    render(conn, "index.html", event_id: event_id, event: event)
  end
end

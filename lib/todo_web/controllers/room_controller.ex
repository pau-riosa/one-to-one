defmodule TodoWeb.RoomController do
  use TodoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

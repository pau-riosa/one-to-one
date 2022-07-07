defmodule TodoWeb.Live.InitAssigns do
  use TodoWeb, :live_view

  def on_mount(:default, _params, _session, socket) do
    timezone = get_connect_params(socket)["timezone"] || "Asia/Manila"
    socket = assign(socket, :timezone, timezone)

    {:cont, socket}
  end

  def on_mount(:private, _params, _session, socket) do
    {:cont, socket}
  end
end

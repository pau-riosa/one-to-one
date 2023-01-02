defmodule TodoWeb.SettingsLive do
  use TodoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Settings")}
  end
end

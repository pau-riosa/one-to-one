defmodule TodoWeb.SettingsLive do
  use TodoWeb, :live_view

  alias Todo.Accounts.User

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Settings", view: :profile)}
  end

  def handle_event("show-session-setting", _session, socket) do
    {:noreply, assign(socket, view: :session_setting)}
  end

  def handle_event("show-profile", _session, socket) do
    {:noreply, assign(socket, view: :profile)}
  end

  def handle_event("show-change-password", _session, socket) do
    {:noreply, assign(socket, view: :change_password)}
  end

  def handle_event("show-change-email", _session, socket) do
    {:noreply, assign(socket, view: :change_email)}
  end
end

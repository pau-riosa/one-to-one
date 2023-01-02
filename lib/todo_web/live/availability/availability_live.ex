defmodule TodoWeb.AvailabilityLive do
  use TodoWeb, :live_view

  alias Todo.Accounts.User

  def mount(_params, _session, socket) do
    socket = assign(socket, view: :availability_hours, page_title: "Availability Hours")
    {:ok, socket}
  end

  def handle_event("show-available-hours", _, socket) do
    {:noreply, assign(socket, view: :availability_hours, page_title: "Availability Hours")}
  end

  def handle_event("show-session-settings", _, socket) do
    changeset = User.session_changeset(socket.assigns.current_user)

    {:noreply,
     assign(socket, changeset: changeset, view: :session_settings, page_title: "Session Settings")}
  end
end

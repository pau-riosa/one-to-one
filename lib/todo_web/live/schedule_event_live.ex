defmodule TodoWeb.ScheduleEventLive do
  use TodoWeb, :live_view
  alias Todo.Accounts

  @impl true
  def mount(%{"time_slot" => _time_slot} = _params, %{"user_token" => user_token}, socket) do
    current_user = Accounts.get_user_by_session_token(user_token)
    socket = assign(socket, current_user: current_user)
    {:ok, socket}
  end
end

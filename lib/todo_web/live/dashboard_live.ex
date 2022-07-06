defmodule TodoWeb.DashboardLive do
  use TodoWeb, :live_view

  alias Todo.Accounts.{User, UserToken}
  alias Todo.Repo

  def mount(_params, %{"user_token" => user_token}, socket) do
    current_user =
      Repo.get_by(UserToken, token: user_token) |> Repo.preload(:user) |> Map.get(:user)

    {:ok, assign(socket, :current_user, current_user)}
  end
end

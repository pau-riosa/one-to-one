defmodule TodoWeb.Settings.Profile do
  use TodoWeb, :live_component

  alias Todo.Accounts

  def update(assigns, socket) do
    changeset = Accounts.change_user_profile(assigns.current_user)

    {:ok,
     assign(socket,
       changeset: changeset,
       current_user: assigns.current_user
     )}
  end

  def handle_event("validate", %{"user" => user} = _params, socket) do
    changeset =
      socket.assigns.current_user
      |> Todo.Accounts.change_user_profile(user)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params} = _params, socket) do
    socket.assigns.current_user
    |> Todo.Accounts.change_user_profile(user_params)
    |> Map.put(:action, :update)
    |> Todo.Repo.update()
    |> case do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profile update.")
         |> push_redirect(to: Routes.settings_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

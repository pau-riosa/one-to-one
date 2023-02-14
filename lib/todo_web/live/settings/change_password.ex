defmodule TodoWeb.Settings.ChangePassword do
  use TodoWeb, :live_component

  alias Todo.Schemas.User

  def update(assigns, socket) do
    changeset = User.password_changeset(assigns.current_user, %{})

    {:ok,
     assign(socket,
       changeset: changeset,
       current_user: assigns.current_user
     )}
  end

  def handle_event("validate", %{"user" => user} = params, socket) do
    changeset =
      socket.assigns.current_user
      |> User.password_changeset(user)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params} = params, socket) do
    user = socket.assigns.current_user

    case Todo.Accounts.reset_user_password(user, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password updated.")
         |> push_redirect(to: Routes.user_session_path(socket, :new))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

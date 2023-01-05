defmodule TodoWeb.Settings.ChangeEmail do
  use TodoWeb, :live_component

  alias Todo.Accounts.User
  alias Todo.Accounts

  def update(assigns, socket) do
    changeset = User.password_changeset(assigns.current_user, %{})

    {:ok,
     assign(socket,
       changeset: changeset,
       current_user: assigns.current_user
     )}
  end

  def handle_event("validate", %{"user" => user_params} = params, socket) do
    %{"current_password" => password, "email" => email} = user_params

    changeset =
      socket.assigns.current_user
      |> User.email_changeset(user_params)
      |> User.validate_current_password(password)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params} = params, socket) do
    %{"current_password" => password, "email" => email} = user_params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_settings_url(socket, :confirm_email, &1)
        )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "A link to confirm your email change has been sent to the new address."
         )
         |> push_redirect(to: Routes.settings_path(socket, :index))}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Oops, something went wrong, please try again.")
         |> push_redirect(to: Routes.settings_path(socket, :index))}
    end
  end
end

defmodule TodoWeb.UserSettingsController do
  use TodoWeb, :controller

  alias Todo.Accounts

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.settings_path(conn, :index))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.settings_path(conn, :index))
    end
  end
end

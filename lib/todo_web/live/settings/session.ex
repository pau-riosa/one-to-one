defmodule TodoWeb.Settings.Session do
  use TodoWeb, :live_component
  alias Todo.Schemas.User
  alias Ecto.Changeset

  def update(assigns, socket) do
    changeset = User.session_changeset(assigns.current_user)
    public_url = build_booking_link(socket, get_slug(changeset))

    {:ok,
     assign(socket,
       public_url: public_url,
       changeset: changeset,
       current_user: assigns.current_user
     )}
  end

  def handle_event("save", %{"user" => params}, socket) do
    socket.assigns.current_user
    |> User.session_changeset(params)
    |> Todo.Repo.update()
    |> case do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Session settings updated.")
         |> push_redirect(to: Routes.settings_path(socket, :index))}

      {:error, changeset} ->
        public_url = build_booking_link(socket, get_slug(changeset))
        {:noreply, assign(socket, public_url: public_url, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      socket.assigns.current_user
      |> User.session_changeset(params)
      |> Map.put(:action, :validate)

    public_url = build_booking_link(socket, get_slug(changeset))

    {:noreply, assign(socket, public_url: public_url, changeset: changeset)}
  end

  def build_booking_link(socket, nil), do: build_booking_link(socket, "")
  def build_booking_link(socket, slug), do: Routes.book_url(socket, :index, slug)

  defp get_slug(%Changeset{changes: %{booking_link: slug}}), do: Inflex.parameterize(slug)
  defp get_slug(%Changeset{data: %{slug: slug}}), do: Inflex.parameterize(slug)
end

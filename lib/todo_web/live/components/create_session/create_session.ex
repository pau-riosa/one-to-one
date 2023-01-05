defmodule TodoWeb.Components.CreateSession do
  use TodoWeb, :live_component

  @moduledoc """
  <.live_component module={TodoWeb.Components.CreateSession} id="create-session" timezone={@timezone} current_user={@current_user} />
  """
  alias Todo.Accounts.UserNotifier
  alias Todo.Schedules.Schedule

  def update(assigns, socket) do
    changeset = Schedule.changeset(%Schedule{})

    {:ok,
     socket
     |> assign(:current_user, assigns.current_user)
     |> assign(:timezone, assigns.timezone)
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"schedule" => schedule} = _params, socket) do
    changeset =
      Schedule.changeset(%Schedule{}, schedule)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"schedule" => schedule} = _params, socket) do
    Schedule.changeset(%Schedule{}, schedule)
    |> Map.put(:action, :insert)
    |> Todo.Repo.insert()
    |> case do
      {:ok, schedule} ->
        schedule = schedule |> Todo.Repo.preload(:created_by)

        UserNotifier.deliver_schedule_instructions(
          schedule,
          TodoWeb.Router.Helpers.url(socket) <>
            Routes.room_path(socket, :index, schedule)
        )

        {:noreply,
         socket
         |> put_flash(:info, "Schedule created.")
         |> push_redirect(to: Routes.booking_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

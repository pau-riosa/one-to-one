defmodule TodoWeb.Book.SetSchedule do
  use TodoWeb, :live_component

  alias Todo.Schedules.{Schedule, Operation}
  alias Todo.Accounts.UserNotifier

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"schedule" => schedule_params} = _params, socket) do
    changeset =
      socket.assigns.changeset
      |> Schedule.set_schedule_changeset(schedule_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"schedule" => schedule_params} = _params, socket) do
    id = schedule_params["schedule_id"]

    schedule =
      Todo.Repo.get!(Schedule, id)
      |> Todo.Repo.preload(:event)

    schedule
    |> Operation.set_schedule(schedule_params)
    |> case do
      {:ok, schedule} ->
        UserNotifier.deliver_schedule_instructions(
          schedule,
          TodoWeb.Router.Helpers.url(socket) <>
            Routes.room_path(socket, :index, schedule_params["schedule_id"])
        )

        {:noreply,
         socket
         |> put_flash(:info, "Schedule successfully booked.")
         |> push_redirect(to: "/")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end

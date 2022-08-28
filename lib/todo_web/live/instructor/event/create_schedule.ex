defmodule TodoWeb.Instructor.Event.CreateSchedule do
  use TodoWeb, :live_component

  alias Todo.Schedules.{Schedule, Operation}
  alias TodoWeb.Components.{CalendarWeeks, Time}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"schedule" => schedule_params} = _params, socket) do
    changeset =
      %Schedule{}
      |> Schedule.changeset(schedule_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"schedule" => schedule_params} = _params, socket) do
    socket.assigns.selected_timeslots
    |> Operation.call(schedule_params)
    |> case do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Schedule created.")
         |> push_redirect(to: Routes.instructor_dashboard_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event(
        "select-time",
        %{"timeslot" => timeslot, "id" => button_id},
        socket
      ) do
    selected_timeslots =
      if Enum.member?(socket.assigns.selected_timeslots, timeslot) do
        socket.assigns.selected_timeslots -- [timeslot]
      else
        [timeslot | socket.assigns.selected_timeslots]
      end

    send_update(Time,
      id: button_id,
      selected_timeslots: selected_timeslots
    )

    {:noreply, assign(socket, :selected_timeslots, selected_timeslots)}
  end
end

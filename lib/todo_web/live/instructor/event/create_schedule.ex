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

    socket = assign(socket, :changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("save", %{"schedule" => schedule_params} = _params, socket) do
    socket.assigns.selected_timeslots
    |> Enum.map(fn timeslot ->
      schedule_params = Map.put(schedule_params, "scheduled_for", timeslot)

      Schedule.changeset(
        %Schedule{},
        schedule_params
      )
    end)
    |> Operation.call()
    |> case do
      {:ok, _} ->
        TodoWeb.Endpoint.broadcast("events", "new_event", %{
          event_id: schedule_params["event_id"]
        })

        socket =
          socket
          |> put_flash(:info, "Schedule created.")
          |> push_redirect(to: Routes.instructor_dashboard_path(socket, :index))

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(:changeset, changeset)

        {:noreply, socket}
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

    socket = assign(socket, :selected_timeslots, selected_timeslots)

    {:noreply, socket}
  end
end

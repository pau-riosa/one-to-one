defmodule TodoWeb.Instructor.ScheduleLive do
  use TodoWeb, :live_view

  alias __MODULE__
  alias Timex
  alias Todo.Schedules
  alias TodoWeb.Components.{CalendarWeeks, Time}
  alias Todo.Events.{Event, Operation}

  @impl true
  def mount(_params, _session, socket) do
    changeset = Event.changeset(%Event{})
    {:ok, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params} = _params, socket) do
    event_params = Map.put(event_params, "schedules", socket.assigns.selected_timeslots)

    changeset =
      %Event{}
      |> Event.changeset(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"event" => event_params} = _params, socket) do
    event_params = Map.put(event_params, "schedules", socket.assigns.selected_timeslots)

    %Event{}
    |> Event.changeset(event_params)
    |> Operation.insert()
    |> case do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created.")
         |> push_redirect(to: Routes.live_path(socket, TodoWeb.Instructor.DashboardLive))}

      {:error, changeset} ->
        error_message = Todo.ChangesetErrorBuilder.call(changeset)

        {:noreply,
         socket
         |> put_flash(:error, "Oops something went wrong. #{error_message}")
         |> assign(:changeset, changeset)}
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

    send_update(Time, id: button_id, selected_timeslots: selected_timeslots)
    {:noreply, assign(socket, :selected_timeslots, selected_timeslots)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, Schedules.assign_dates(socket, params)}
  end
end

defmodule TodoWeb.Instructor.EventLive do
  use TodoWeb, :live_view

  alias __MODULE__
  alias TodoWeb.Components.{CalendarWeeks, Time}
  alias Todo.Events.Event
  alias Todo.Schedules.Schedule
  alias Todo.Schedules

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    schedule_changeset = Schedule.changeset(%Schedule{})

    socket =
      socket
      |> assign(:schedule_changeset, schedule_changeset)
      |> assign(:existing_timeslots, Schedules.get_all_schedules(current_user.id))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    changeset =
      case params["event_id"] do
        event_id when is_binary(event_id) ->
          Todo.Repo.get(Event, event_id)
          |> Event.changeset()

        _ ->
          %Event{}
          |> Event.changeset()
      end

    socket =
      socket
      |> Schedules.assign_dates(params)
      |> assign(event_changeset: changeset)
      |> assign(event_id: params["event_id"])

    {:noreply, socket}
  end
end

defmodule TodoWeb.BookLive do
  use TodoWeb, :live_view

  alias Todo.Events
  alias Todo.Events.Event
  alias Todo.Schedules
  alias Todo.Schedules.Schedule
  alias TodoWeb.Components.CalendarMonths

  def mount(_params, _session, socket) do
    events = Events.all()

    {:ok,
     socket
     |> assign(:events, events)}
  end

  def handle_params(%{"class" => class_slug, "schedule" => datetime} = params, _session, socket) do
    schedule = Schedules.get_by_slug_and_datetime(class_slug, datetime)
    changeset = Schedule.changeset(schedule)

    {:noreply,
     socket
     |> Schedules.assign_dates(params)
     |> assign(:schedule, schedule)
     |> assign(:changeset, changeset)
     |> assign(:page_title, "Book Schedule")}
  end

  def handle_params(%{"class" => class_slug, "date" => date} = params, _session, socket) do
    event = Events.get_by_slug(class_slug)

    schedules = Schedules.get_by_slug_and_date(class_slug, date)

    {:noreply,
     socket
     |> Schedules.assign_dates(params)
     |> assign(:schedules, schedules)
     |> assign(:event, event)
     |> assign(:page_title, "Select Date")}
  end

  def handle_params(%{"class" => class_slug} = params, _session, socket) do
    event = Events.get_by_slug(class_slug)

    socket =
      socket
      |> Schedules.assign_dates(params)
      |> assign(:schedules, [])
      |> assign(:page_title, "Select Class")

    {:noreply, socket |> assign(:event, event)}
  end

  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "delete-event",
        %{"id" => id} = _params,
        %{assigns: %{current_user: user}} = socket
      ) do
    case Events.delete(id) do
      {:ok, %Event{} = event} ->
        events = Events.get_events_by_created_by_id(user.id)
        {:noreply, socket |> assign(:events, events)}

      {:error, error} ->
        {:noreply, socket}
    end
  end
end

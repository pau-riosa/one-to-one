defmodule TodoWeb.Instructor.ScheduleLive do
  use TodoWeb, :live_view

  alias __MODULE__
  alias Timex
  alias Timex.Duration
  alias TodoWeb.Components.{CalendarWeeks, Time}
  alias Todo.Events.Event
  alias Todo.Repo

  @impl true
  def mount(_params, _session, socket) do
    changeset = Event.changeset(%Event{})
    socket = assign(socket, :changeset, changeset)
    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params} = _params, socket) do
    event_params = Map.put(event_params, "schedules", socket.assigns.selected_timeslots)

    changeset =
      %Event{}
      |> Event.changeset(event_params)
      |> Map.put(:action, :validate)

    socket = assign(socket, :changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("save", %{"event" => event_params} = _params, socket) do
    event_params = Map.put(event_params, "schedules", socket.assigns.selected_timeslots)

    changeset =
      %Event{}
      |> Event.changeset(event_params)
      |> Map.put(:action, :insert)
      |> Repo.insert()

    case changeset do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, "Oops something went wrong.")

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> put_flash(:error, "Oops something went wrong.")
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

    send_update(Time, id: button_id, selected_timeslots: selected_timeslots)
    socket = assign(socket, :selected_timeslots, selected_timeslots)

    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket = assign_dates(socket, params)
    {:noreply, socket}
  end

  defp assign_dates(socket, params) do
    current = current_from_params(socket, params)
    beginning_of_month = Timex.beginning_of_month(current)
    end_of_month = Timex.end_of_month(current)

    end_of_week = Timex.end_of_week(current)

    beginning_of_week = Timex.beginning_of_week(current)

    display_list_of_time = {"time", list_of_time(current)}

    current_week =
      Timex.Interval.new(from: beginning_of_week, until: [days: 6], right_open: false)
      |> Timex.Interval.with_step(days: 1)
      |> Enum.map(fn date ->
        {date, list_of_time(date)}
      end)

    current_week = [display_list_of_time | current_week]

    previous_month =
      beginning_of_month
      |> Timex.add(Duration.from_days(-1))
      |> date_to_month

    next_month =
      end_of_month
      |> Timex.add(Duration.from_days(1))
      |> date_to_month

    previous_week =
      beginning_of_week
      |> Timex.add(Duration.from_days(-1))
      |> date_to_week

    next_week =
      end_of_week
      |> Timex.add(Duration.from_days(7))
      |> date_to_week

    socket
    |> assign(selected_timeslots: [])
    |> assign(current: current)
    |> assign(beginning_of_month: beginning_of_month)
    |> assign(end_of_month: end_of_month)
    |> assign(beginning_of_week: beginning_of_week)
    |> assign(end_of_week: end_of_week)
    |> assign(previous_month: previous_month)
    |> assign(next_month: next_month)
    |> assign(current_week: current_week)
    |> assign(previous_week: previous_week)
    |> assign(next_week: next_week)
    |> assign(page_title: "Schedule")
  end

  defp current_from_params(socket, %{"datetime" => datetime}) do
    case Timex.parse("#{datetime}", "{YYYY}-{0M}-{D} {h24}:{m}:00") do
      {:ok, current} -> NaiveDateTime.to_date(current)
      _ -> Timex.today(socket.assigns.timezone)
    end
  end

  defp current_from_params(socket, %{"week" => week}) do
    case Timex.parse("#{week}", "{YYYY}-{0M}-{D}") do
      {:ok, current} -> NaiveDateTime.to_date(current)
      _ -> Timex.today(socket.assigns.timezone)
    end
  end

  defp current_from_params(socket, %{"date" => date}) do
    case Timex.parse("#{date}", "{YYYY}-{0M}-{D}") do
      {:ok, current} -> NaiveDateTime.to_date(current)
      _ -> Timex.today(socket.assigns.timezone)
    end
  end

  defp current_from_params(socket, %{"month" => month}) do
    case Timex.parse("#{month}", "{YYYY}-{0M}") do
      {:ok, current} -> NaiveDateTime.to_date(current)
      _ -> Timex.today(socket.assigns.timezone)
    end
  end

  defp current_from_params(socket, _) do
    Timex.today(socket.assigns.timezone)
  end

  defp list_of_time(date) do
    Timex.Interval.new(from: date, until: [days: 1], left_open: false)
    |> Timex.Interval.with_step(minutes: 30)
    |> Enum.map(& &1)
  end

  defp date_to_week(datetime) do
    Timex.format!(datetime, "{YYYY}-{0M}-{D}")
  end

  defp date_to_month(datetime) do
    Timex.format!(datetime, "{YYYY}-{0M}")
  end
end

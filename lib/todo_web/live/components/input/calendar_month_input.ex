defmodule TodoWeb.Components.CalendarMonthInput do
  @moduledoc """
    <.live_component module={TodoWeb.Components.CalendarMonths}
        id="datetime-input"
        form={f}
        field={:date}
        timezone={@timezone}
        />
  """
  use TodoWeb, :live_component

  alias Timex.Duration
  alias Timex
  alias Todo.Schedules

  def mount(socket) do
    socket =
      socket
      |> assign_dates()
      |> assign(show_calendar: false)

    {:ok, socket}
  end

  def preload([%{timezone: timezone}] = list_of_assigns) do
    Enum.map(list_of_assigns, fn assign ->
      assign
      |> Map.put(:timezone, timezone)
      |> Map.put(:date, Todo.Helpers.Tempo.today_date(timezone))
    end)
  end

  def handle_event("select-date", %{"selected-date" => selected_date}, socket) do
    booked_schedules =
      Schedules.get_schedules_by_created_by_id(socket.assigns.current_user.id)
      |> Enum.map(
        &(&1.scheduled_for
          |> Timex.to_datetime(socket.assigns.timezone)
          |> Timex.format!("%I:%M %p", :strftime))
      )

    send_update(TodoWeb.Components.TimeInput,
      id: "time-input",
      selected_date: selected_date,
      timezone: socket.assigns.timezone,
      booked_schedules: booked_schedules
    )

    socket =
      socket
      |> assign(date: selected_date)
      |> assign(show_calendar: false)

    {:noreply, socket}
  end

  def handle_event("previous-month", %{"previous-month" => month}, socket) do
    {:noreply, assign_dates(socket, month)}
  end

  def handle_event("next-month", %{"next-month" => month}, socket) do
    {:noreply, assign_dates(socket, month)}
  end

  def handle_event("toggle-show-calendar", _, socket) do
    {:noreply, assign(socket, show_calendar: !socket.assigns.show_calendar)}
  end

  def handle_event("hide-calendar", _, socket) do
    {:noreply, assign(socket, show_calendar: false)}
  end

  def current_from_params(month, timezone \\ Timex.Timezone.local()) do
    case Timex.parse("#{month}", "{YYYY}-{0M}") do
      {:ok, current} ->
        if current.month == NaiveDateTime.local_now().month,
          do: NaiveDateTime.to_date(Timex.now()),
          else: NaiveDateTime.to_date(current)

      _ ->
        Timex.today(timezone)
    end
  end

  def assign_dates(socket, date \\ Timex.now()) do
    current = current_from_params(date)
    beginning_of_month = Timex.beginning_of_month(current)
    end_of_month = Timex.end_of_month(current)

    previous_month =
      beginning_of_month
      |> Timex.add(Duration.from_days(-1))
      |> Schedules.date_to_month()

    next_month =
      end_of_month
      |> Timex.add(Duration.from_days(1))
      |> Schedules.date_to_month()

    socket
    |> assign(current: current)
    |> assign(beginning_of_month: beginning_of_month)
    |> assign(end_of_month: end_of_month)
    |> assign(previous_month: previous_month)
    |> assign(next_month: next_month)
  end
end

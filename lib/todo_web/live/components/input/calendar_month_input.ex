defmodule TodoWeb.Components.CalendarMonthInput do
  use TodoWeb, :live_component

  alias Timex.Duration
  alias Timex
  alias Todo.Schedules

  @doc """

    <CalendarMonths.calendar_months
        id="datetime-input"
        form={f}
        field={:date}
        timezone={@timezone}
       
        />
  """

  def mount(socket) do
    socket =
      socket
      |> assign_dates()
      |> assign(show_calendar: false)
      |> assign(date: "")

    {:ok, socket}
  end

  def preload(list_of_assigns) do
    Enum.map(list_of_assigns, fn assign ->
      Map.put(assign, :timezone, assign[:timezone])
    end)
  end

  def handle_event("select-date", %{"selected-date" => date}, socket) do
    socket =
      socket
      |> assign(date: date)
      |> assign(show_calendar: false)

    {:noreply, socket}
  end

  def handle_event("previous-month", %{"previous-month" => month}, socket) do
    socket = socket |> assign_dates(month)
    {:noreply, socket}
  end

  def handle_event("next-month", %{"next-month" => month}, socket) do
    socket = socket |> assign_dates(month)
    {:noreply, socket}
  end

  def handle_event("show-calendar", _, socket) do
    {:noreply, assign(socket, show_calendar: true)}
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

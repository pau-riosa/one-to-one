defmodule TodoWeb.DashboardLive do
  use TodoWeb, :live_view

  alias Todo.Accounts
  alias Timex
  alias Timex.Duration

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    current_user = Accounts.get_user_by_session_token(user_token)
    socket = assign(socket, current_user: current_user)
    {:ok, socket}
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

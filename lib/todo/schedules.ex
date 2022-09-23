defmodule Todo.Schedules do
  @moduledoc """
  The Schedules context
  """
  import Ecto.Query
  import Phoenix.LiveView, only: [assign: 2, assign: 3]
  alias Timex
  alias Timex.Duration
  alias Todo.Schedules.Schedule
  alias Todo.Repo

  def get_by_slug_and_datetime(slug, datetime) do
    {:ok, datetime, _} = datetime |> DateTime.from_iso8601()

    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where([s, event: e], e.slug == ^slug and s.scheduled_for == ^datetime)
    |> preload(event: :created_by)
    |> select([s], s)
    |> Repo.one()
  end

  def get_by_slug_and_date(slug, date) do
    date =
      Timex.parse!(date, "%Y-%m-%d", :strftime)
      |> Timex.to_date()

    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where(
      [s, event: e],
      fragment("?::date = ?::date", s.scheduled_for, ^date)
    )
    |> select([s], s.scheduled_for)
    |> Repo.all()
  end

  def get_all_past_schedules(created_by_id) do
    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.created_by_id == ^created_by_id)
    |> where([s], s.scheduled_for < ^Timex.now())
    |> select([s, event: e], %{
      event: e,
      id: s.id,
      scheduled_for: s.scheduled_for
    })
    |> Repo.all()
  end

  def get_all_schedules(created_by_id) do
    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.created_by_id == ^created_by_id)
    |> select([s], s.scheduled_for)
    |> Repo.all()
  end

  def get_schedules_by_event_ids(event_ids) when is_list(event_ids) do
    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.id in ^event_ids)
    |> order_by([s], desc: s.scheduled_for)
    |> Repo.all()
  end

  def get_schedules_by_event_id(event_id) when is_binary(event_id) do
    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.id == ^event_id)
    |> order_by([s], desc: s.scheduled_for)
    |> Repo.all()
  end

  def get_schedules_by_created_by_id(created_by_id, current_date \\ Timex.now())
      when is_binary(created_by_id) do
    beginning_of_day = Timex.beginning_of_day(current_date)
    end_of_day = Timex.end_of_day(current_date)

    Schedule
    |> join(:inner, [s], e in assoc(s, :event), as: :event)
    |> where([event: e], e.created_by_id == ^created_by_id)
    |> where([s], fragment("? BETWEEN ? AND ?", s.scheduled_for, ^beginning_of_day, ^end_of_day))
    |> select([s, event: e], %{
      event: e,
      id: s.id,
      scheduled_for: s.scheduled_for
    })
    |> order_by([s], desc: s.scheduled_for)
    |> Repo.all()
  end

  def get_current_schedules(socket, params) do
    current = current_from_params(socket, params)

    schedules =
      case params["class"] do
        "upcoming" ->
          get_schedules_by_created_by_id(
            socket.assigns.current_user.id,
            Timex.to_naive_datetime(current)
          )

        "past" ->
          get_all_past_schedules(socket.assigns.current_user.id)

        _ ->
          get_schedules_by_created_by_id(
            socket.assigns.current_user.id,
            Timex.to_naive_datetime(current)
          )
      end

    assign(socket, :schedules, schedules)
  end

  def assign_dates(socket, params) do
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
  end

  def current_from_params(socket, %{"datetime" => datetime}) do
    case Timex.parse("#{datetime}", "{YYYY}-{0M}-{D} {h24}:{m}:00") do
      {:ok, current} -> NaiveDateTime.to_date(current)
      _ -> Timex.today(socket.assigns.timezone)
    end
  end

  def current_from_params(socket, %{"week" => week}) do
    case Timex.parse("#{week}", "{YYYY}-{0M}-{D}") do
      {:ok, current} -> NaiveDateTime.to_date(current)
      _ -> Timex.today(socket.assigns.timezone)
    end
  end

  def current_from_params(socket, %{"date" => date}) do
    case Timex.parse("#{date}", "{YYYY}-{0M}-{D}") do
      {:ok, current} -> NaiveDateTime.to_date(current)
      _ -> Timex.today(socket.assigns.timezone)
    end
  end

  def current_from_params(socket, %{"month" => month}) do
    case Timex.parse("#{month}", "{YYYY}-{0M}") do
      {:ok, current} -> NaiveDateTime.to_date(current)
      _ -> Timex.today(socket.assigns.timezone)
    end
  end

  def current_from_params(socket, _) do
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

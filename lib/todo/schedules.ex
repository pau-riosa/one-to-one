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
    |> join(:inner, [s], e in assoc(s, :created_by), as: :created_by)
    |> where([s, created_by: e], e.slug == ^slug and s.scheduled_for == ^datetime)
    |> preload(event: :created_by)
    |> select([s], s)
    |> Repo.one()
  end

  def get_by_slug_and_date(slug, date) do
    date =
      Timex.parse!(date, "%Y-%m-%d", :strftime)
      |> Timex.to_date()

    Schedule
    |> join(:inner, [s], e in assoc(s, :created_by), as: :created_by)
    |> where([created_by: e], e.slug == ^slug)
    |> where([s], fragment("?::date = ?::date", s.scheduled_for, ^date))
    |> where([s], is_nil(s.email))
    |> select([s], s.scheduled_for)
    |> Repo.all()
  end

  def get_all_past_schedules(created_by_id, timezone \\ "Etc/UTC") do
    Schedule
    |> where([s], s.created_by_id == ^created_by_id)
    |> where([s], s.scheduled_for < ^Timex.now(timezone))
    |> order_by([s], desc: s.scheduled_for)
    |> Repo.all()
  end

  def get_all_schedules(created_by_id) do
    Schedule
    |> where([s], s.created_by_id == ^created_by_id)
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

  def get_schedules_by_created_by_id(
        created_by_id,
        current_date \\ Timex.now(),
        timezone \\ "Etc/UTC"
      )
      when is_binary(created_by_id) do
    beginning_of_day = Timex.now(timezone)

    end_of_day =
      timezone
      |> Timex.now()
      |> Timex.end_of_day()

    Schedule
    |> where([s], s.created_by_id == ^created_by_id)
    |> where([s], s.scheduled_for >= ^beginning_of_day and s.scheduled_for <= ^end_of_day)
    |> order_by([s], desc: s.scheduled_for)
    |> Repo.all()
  end

  def get_current_schedules(socket, params) do
    current = current_from_params(socket, params)

    schedules =
      case params["session"] do
        "upcoming" ->
          get_schedules_by_created_by_id(
            socket.assigns.current_user.id,
            Timex.to_naive_datetime(current),
            socket.assigns.timezone
          )

        "past" ->
          get_all_past_schedules(socket.assigns.current_user.id, socket.assigns.timezone)

        _ ->
          get_schedules_by_created_by_id(
            socket.assigns.current_user.id,
            Timex.to_naive_datetime(current),
            socket.assigns.timezone
          )
      end

    assign(socket, :schedules, schedules)
  end

  def assign_dates(socket, params \\ %{}) do
    current = current_from_params(socket, params)
    beginning_of_month = Timex.beginning_of_month(current)
    end_of_month = Timex.end_of_month(current)

    previous_month =
      beginning_of_month
      |> Timex.add(Duration.from_days(-1))
      |> date_to_month

    next_month =
      end_of_month
      |> Timex.add(Duration.from_days(1))
      |> date_to_month

    socket
    |> assign(selected_timeslots: [])
    |> assign(current: current)
    |> assign(beginning_of_month: beginning_of_month)
    |> assign(end_of_month: end_of_month)
    |> assign(previous_month: previous_month)
    |> assign(next_month: next_month)
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

  def list_of_time(date) do
    Timex.Interval.new(from: date, until: [days: 1], left_open: false)
    |> Timex.Interval.with_step(minutes: 30)
    |> Enum.map(& &1)
  end

  def date_to_week(datetime) do
    Timex.format!(datetime, "{YYYY}-{0M}-{D}")
  end

  def date_to_month(datetime) do
    Timex.format!(datetime, "{YYYY}-{0M}")
  end
end

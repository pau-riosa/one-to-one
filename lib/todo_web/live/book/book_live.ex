defmodule TodoWeb.BookLive do
  use TodoWeb, :live_view

  alias Todo.Events
  alias Todo.Schedules
  alias Todo.Schedules.Schedule
  alias Todo.Accounts.User

  def mount(%{"slug" => slug} = params, _session, socket) do
    case Todo.Accounts.get_user_by_slug(slug) do
      %User{} = book_with ->
        schedules = []

        {:ok,
         socket
         |> Schedules.assign_dates(params)
         |> assign(:book_with, book_with)
         |> assign(:slug, slug)
         |> assign(:schedules, schedules)}

      _ ->
        {:ok, socket, layout: {TodoWeb.LayoutView, "not_found.html"}}
    end
  end

  def handle_params(%{"slug" => slug, "schedule" => schedule} = params, _session, socket) do
    book_with = Todo.Accounts.get_user_by_slug(slug)
    changeset = Schedule.set_schedule_changeset(%Schedule{})

    {:noreply,
     socket
     |> Schedules.assign_dates(params)
     |> assign(:book_with, book_with)
     |> assign(:schedule, schedule)
     |> assign(:changeset, changeset)
     |> assign(:page_title, "Book Schedule")}
  end

  def handle_params(%{"slug" => slug, "date" => date} = params, _session, socket) do
    book_with = Todo.Accounts.get_user_by_slug(slug)
    date = to_datetime(socket, date)

    schedules =
      list_of_time(date, 30)
      |> Enum.map(fn f ->
        f
        |> NaiveDateTime.to_iso8601()
        |> Timex.parse!("{ISO:Extended}")
      end)

    {:noreply,
     socket
     |> assign(:book_with, book_with)
     |> assign(:schedules, schedules)
     |> assign(:page_title, "Select Schedule")
     |> Schedules.assign_dates(params)}
  end

  def handle_params(%{"slug" => slug} = params, _session, socket) do
    book_with = Todo.Accounts.get_user_by_slug(slug)

    {:noreply,
     socket
     |> assign(:schedules, [])
     |> assign(:book_with, book_with)
     |> assign(:page_title, "Select Date")
     |> Schedules.assign_dates(params)}
  end

  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  defp to_datetime(socket, date) do
    case Timex.parse("#{date}", "{YYYY}-{0M}-{D}") do
      {:ok, current} -> NaiveDateTime.to_date(current)
      _ -> Timex.today(socket.assigns.timezone)
    end
  end

  def list_of_time(date, duration) do
    Timex.Interval.new(from: date, until: [days: 1], left_open: false)
    |> Timex.Interval.with_step(minutes: duration)
    |> Enum.map(& &1)
  end
end

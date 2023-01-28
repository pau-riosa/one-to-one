defmodule TodoWeb.BookLive do
  use TodoWeb, :live_view

  alias Todo.Events
  alias Todo.Schedules
  alias Todo.Schedules.Schedule
  alias Todo.Accounts.User
  alias Todo.Tempo

  @default_duration 20
  def mount(%{"slug" => slug} = params, _session, socket) do
    case Todo.Accounts.get_user_by_slug(slug) do
      %User{} = book_with ->
        {:ok,
         socket
         |> Schedules.assign_dates(params)
         |> assign(:book_with, book_with)
         |> assign(:slug, slug)
         |> assign(:schedules, [])}

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
    timezone = Map.get(socket.assigns.book_with, :timezone, "Asia/Manila")
    duration = Map.get(socket.assigns.book_with, :duration, @default_duration)
    book_with = Todo.Accounts.get_user_by_slug(slug)
    schedules = Tempo.list_of_times(date, timezone, duration)

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
end

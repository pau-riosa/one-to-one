defmodule TodoWeb.BookLive do
  use TodoWeb, :live_view

  alias Todo.Schedules
  alias Todo.Schemas.Schedule
  alias Todo.Schemas.User
  alias Todo.Helpers.Tempo
  @topic "update_booked_schedules"
  @default_duration 20

  @impl Phoenix.LiveView
  def mount(%{"slug" => slug} = params, _session, socket) do
    TodoWeb.Endpoint.subscribe(@topic)

    case Todo.Accounts.get_user_by_slug(slug) do
      %User{} = book_with ->
        {:ok,
         socket
         |> Schedules.assign_dates(params)
         |> assign(:book_with, book_with)
         |> assign(:slug, slug)
         |> assign(:schedules, [])
         |> assign(:local_timezone, "")
         |> assign(:booked_schedules, [])}

      _ ->
        {:ok, socket, layout: {TodoWeb.LayoutView, "not_found.html"}}
    end
  end

  @impl Phoenix.LiveView
  def handle_info(%{event: "update", payload: %{"reload" => true}}, socket) do
    timezone = socket.assigns.timezone
    book_with = socket.assigns.book_with

    booked_schedules =
      Schedules.get_schedules_by_created_by_id(book_with.id)
      |> Enum.map(
        &(&1.scheduled_for
          |> Timex.to_datetime(timezone)
          |> Timex.format!("%I:%M %p", :strftime))
      )

    {:noreply, assign(socket, :booked_schedules, booked_schedules)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"slug" => slug, "schedule" => schedule} = params, _session, socket) do
    book_with = Todo.Accounts.get_user_by_slug(slug)
    changeset = Schedule.changeset(%Schedule{})

    {:noreply,
     socket
     |> Schedules.assign_dates(params)
     |> assign(:book_with, book_with)
     |> assign(:schedule, schedule)
     |> assign(:changeset, changeset)
     |> assign(:page_title, "Book Schedule")}
  end

  def handle_params(%{"slug" => slug, "date" => date} = params, _session, socket) do
    timezone = socket.assigns.timezone
    duration = Map.get(socket.assigns.book_with, :duration, @default_duration)
    book_with = Todo.Accounts.get_user_by_slug(slug)

    booked_schedules =
      Schedules.get_schedules_by_created_by_id(book_with.id)
      |> Enum.map(
        &(&1.scheduled_for
          |> Timex.to_datetime(timezone)
          |> Timex.format!("%I:%M %p", :strftime))
      )

    schedules = Tempo.list_of_times(date, timezone, duration)

    {:noreply,
     socket
     |> assign(:book_with, book_with)
     |> assign(:booked_schedules, booked_schedules)
     |> assign(:schedules, schedules)
     |> assign(:page_title, "Select Schedule")
     |> Schedules.assign_dates(params)}
  end

  def handle_params(%{"slug" => slug} = params, _session, socket) do
    book_with = Todo.Accounts.get_user_by_slug(slug)

    {:noreply,
     socket
     |> assign(:schedules, [])
     |> assign(:booked_schedules, [])
     |> assign(:book_with, book_with)
     |> assign(:page_title, "Select Date")
     |> Schedules.assign_dates(params)}
  end

  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end

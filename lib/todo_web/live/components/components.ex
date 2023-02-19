defmodule TodoWeb.Components do
  use TodoWeb, :component

  alias Todo.Repo

  def confirm_banner(
        %{socket: socket, current_user: %{confirmed_at: confirmed_at} = _current_user} = assigns
      )
      when is_nil(confirmed_at) do
    ~H"""
        <div class="bg-indigo-600">
          <div class="mx-auto max-w-7xl py-3 px-3 sm:px-6 lg:px-8 text-center">
            <p class="truncate font-medium text-white">
              <span class="md:hidden">Kindly confirm your account by checking your email.</span>
              <span class="hidden md:inline">We just want to make sure your are enjoying this. Kindly confirm you account by checking your email.</span>
            </p>
          </div>
        </div>
    """
  end

  def confirm_banner(assigns), do: ~H""

  def schedule(
        %{
          booked_schedules: booked_schedules,
          schedule: schedule,
          timezone: timezone,
          slug: slug,
          socket: socket
        } = assigns
      ) do
    datetime =
      schedule
      |> Timex.to_datetime(timezone)
      |> DateTime.to_iso8601()

    path = Routes.book_path(socket, :set_schedule, slug, datetime) |> URI.decode()
    time = Timex.format!(schedule, "%I:%M %p", :strftime)

    class =
      class_list([
        {"border border-blue-900 p-2 rounded rounded-lg bg-blue-900 text-white hover:bg-white hover:text-blue-900 w-3/5 text-center",
         true}
      ])

    assigns =
      assigns
      |> assign(path: path)
      |> assign(time: time)
      |> assign(class: class)
      |> assign(booked_schedules: booked_schedules)

    ~H"""
    <%= if @time not in @booked_schedules do %>
      <%= live_patch @time, to: @path, class: @class  %>
    <% end %>
    """
  end

  @doc """
    <TodoWeb.Components.calendar_months
        id="calendar"
        current_path={Routes.dashboard_path(@socket, :index)}
        previous_month={@previous_month}
        next_month={@next_month}
        end_of_month={@end_of_month}
        beginning_of_month={@beginning_of_month}
        timezone={@timezone}
        current={@current}
        socket={@socket}
        />
  """
  def calendar_months(
        %{
          current: current,
          current_path: current_path,
          previous_month: previous_month,
          next_month: next_month
        } = assigns
      ) do
    previous_month_path = build_path(current_path, %{month: previous_month})
    next_month_path = build_path(current_path, %{month: next_month})

    assigns =
      assigns
      |> assign(previous_month_path: previous_month_path)
      |> assign(next_month_path: next_month_path)

    ~H"""
    <div>
        <div class="flex items-center mb-8">
            <div class="flex-1 text-blue-900 font-semibold">
                <%= Timex.format!(@current, "%B %Y", :strftime)%> 
            </div>
            <div class="flex justify-end flex-1 text-right">
                <%= live_patch to: @previous_month_path do %>
                    <button class="flex items-center justify-center w-5 h-5 text-blue-700 align-middle rounded-full hover:bg-blue-200">
                        <i><%= Heroicons.icon("chevron-left", type: "solid", class: "h-5 w-5  fill-blue-900") %></i>
                    </button>
                <% end %>
                <%= live_patch to: @next_month_path do %>
                <button class="flex items-center justify-center w-5 h-5 text-blue-700 align-middle rounded-full hover:bg-blue-200">
                    <i><%= Heroicons.icon("chevron-right", type: "solid", class: "h-5 w-5 fill-blue-900") %></i>
                </button>
                <% end %>
            </div>
        </div>
        <div class="mb-6 text-center text-blue-900 uppercase calendar grid grid-cols-7 gap-y-2 gap-x-2">
            <div class="text-xs">Sun</div>
            <div class="text-xs">Mon</div>
            <div class="text-xs">Tue</div>
            <div class="text-xs">Wed</div>
            <div class="text-xs">Thu</div>
            <div class="text-xs">Fri</div>
            <div class="text-xs">Sat</div>
            <%= for i <- 0..(@end_of_month.day - 1) do %>
                  <TodoWeb.Components.day
                    index={i}
                    current={@current}
                    date={Timex.shift(@beginning_of_month, days: i)}
                    current_path={@current_path}
                    timezone={@timezone}
                  />
            <% end %>
        </div>
        <div class="flex items-center gap-x-1 text-blue">
            <i><%= Heroicons.icon("globe-asia-australia", type: "solid", class: "h-7 w-7 fill-blue-900") %></i>
            <%= @timezone %> 
        </div>
    </div>
    """
  end

  def day(
        %{
          index: index,
          current: current,
          current_path: current_path,
          timezone: timezone,
          date: date
        } = assigns
      ) do
    date_path = build_path(current_path, %{date: date})
    disabled = Timex.compare(date, Timex.today(timezone)) == -1
    weekday = Timex.weekday(date, :sunday)

    class =
      class_list([
        {"grid-column-#{weekday}", index == 0},
        {"content-center font-semibold w-10 h-10 rounded-full justify-center items-center flex",
         true},
        {"bg-blue-900 text-white font-bold", not disabled and current == date},
        {"bg-blue-50 text-blue-900 hover:bg-blue-900 hover:text-white",
         not disabled and current != date},
        {"text-gray-200 cursor-default pointer-events-none", disabled}
      ])

    assigns =
      assigns
      |> assign(disabled: disabled)
      |> assign(text: Timex.format!(date, "{D}"))
      |> assign(date_path: date_path)
      |> assign(class: class)

    ~H"""
    <%= live_patch to: @date_path, class: @class, disabled: @disabled  do %>
      <%= @text %> 
    <% end %>
    """
  end

  def calendar_weeks(
        %{
          id: id,
          socket: socket,
          current_path: current_path,
          previous_week: previous_week,
          next_week: next_week,
          timezone: timezone,
          selected_timeslots: selected_timeslots,
          existing_timeslots: existing_timeslots
        } = assigns
      ) do
    previous_week_path = build_path(current_path, %{week: previous_week})
    next_week_path = build_path(current_path, %{week: next_week})

    assigns =
      assigns
      |> assign(previous_week_path: previous_week_path)
      |> assign(next_week_path: next_week_path)
      |> assign(id: id)
      |> assign(selected_timeslots: selected_timeslots)

    ~H"""
        <div class="flex flex-row px-6 justify-center align-center gap-x-5">
          <%= live_patch to: @previous_week_path do %> 
        <button class="flex items-center justify-center w-10 h-10 text-blue-700 align-middle rounded-full hover:bg-blue-200">
                    <i><%= Heroicons.icon("chevron-left", type: "solid", class: "h-10 w-10 fill-blue-900") %></i>
        </button>
        <% end %>
            <div class="flex flex-row items-center mb-2 text-gray-500 gap-2">
                <h1 class="my-3 text-xl text-black"><%= Timex.format!(@beginning_of_week, "%B %d", :strftime) %> - <%= Timex.format!(@end_of_week, "%d %Y", :strftime)%></h1>
            </div>
          <%= live_patch to: @next_week_path do %> 
            <button class="flex items-center justify-center w-10 h-10 text-blue-700 align-middle rounded-full hover:bg-blue-200">
                <i><%= Heroicons.icon("chevron-right", type: "solid", class: "h-10 w-10 fill-blue-900") %></i>
            </button>
        <% end %>
        </div>

        <div class="py-2 px-5 text-center grid grid-cols-8 gap-2" id={@id}>
          <%= for {{date, list_of_time}, date_index} <- Enum.with_index(@current_week) do %>
              <div class="flex flex-col gap-2">
                <div class="text-xs font-semibold text-blue-900"><%= if date == "time", do: "-", else: Timex.format!(date, "%a %m-%d", :strftime) %></div>
                  <%= for {time, time_index} <- Enum.with_index(list_of_time) do %>
                    <.live_component module={TodoWeb.Components.Time}
                      id={"time-#{date_index}-#{time_index}"}
                      parent_id={@id}
                      date={date}
                      datetime={time}
                      timezone={timezone}
                      current_path={current_path}
                      button_id={"button-#{date_index}-#{time_index}"}
                      selected_timeslots={selected_timeslots}
                      existing_timeslots={existing_timeslots}
                    />
                  <% end %>
              </div> 
          <% end %>
        </div>
    """
  end
end

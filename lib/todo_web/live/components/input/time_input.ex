defmodule TodoWeb.Components.TimeInput do
  use TodoWeb, :live_component
  alias Todo.Tempo
  @minutes_step 20
  defp default_next_day_time, do: "08:00 AM"

  @moduledoc """
          <.live_component module={TodoWeb.Components.TimeInput}
                    id={"time-input"}
                    index={i}
                    current={@current}
                    date={Timex.shift(@beginning_of_month, days: i)}
                    timezone={@timezone}
                    field={@field}
                    form={@form}
                    />

  """
  def render(assigns) do
    class =
      class_list([
        {"p-3 bg-blue-700 hover:bg-blue-900 text-blue-900 hover:text-white text-md font-semibold cursor-pointer",
         true}
      ])

    assigns =
      assigns
      |> assign(class: class)
      |> assign(label: Map.get(assigns, :label, true))

    ~H"""
    <div class="flex flex-col w-full">
        <%= if @label do %>
          <label class="text-sm text-blue-900 font-normal"><%= Atom.to_string(@field) |> String.capitalize %></label>
        <% end %>
        <div class="flex flex-row justify-between border border-gray-300 my-1 items-center rounded-md bg-white px-3 py-3">
          <%= select @form, @field, @times, selected: default_next_day_time(), class: "appearance-none w-full text-blue-900 font-md focus:outline-none focus:ring-blue focus:border-blue focus:z-10 sm:text-sm" %>
          <i><%= Heroicons.icon("clock", type: "solid", class: "h-5 w-5 fill-blue-900") %></i>
        </div>
        <%= error_tag @form, @field %>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def preload([%{date: date, timezone: timezone}] = list_of_assigns) do
    Enum.map(list_of_assigns, fn assign ->
      selected_date = Date.from_iso8601!(date)
      today_date = Tempo.today_date(timezone)

      same_day? = Tempo.same_day?(selected_date, today_date)

      times = list_of_times(same_day?, timezone, @minutes_step)

      Map.put(assign, :times, times)
    end)
  end

  def preload([%{timezone: timezone}] = list_of_assigns) do
    Enum.map(list_of_assigns, fn assign ->
      times = list_of_times(true, timezone, @minutes_step)
      date = DateTime.to_date(Tempo.now!(timezone))

      assign
      |> Map.put(:times, times)
      |> Map.put(:date, date)
    end)
  end

  def list_of_times(same_day, timezone, step \\ @minutes_step)

  def list_of_times(false = _same_day, _timezone, step) do
    make_interval_times(~D[2014-09-22], [days: 1], step)
  end

  def list_of_times(true = _same_day, timezone, step) do
    %{minute: minute} = datetime_now = Tempo.now!(timezone)

    dt_updated =
      Timex.shift(datetime_now, minutes: minutes_ceil(minute))
      |> Timex.set(second: 0, microsecond: {000_000, 6})

    dt_naive = NaiveDateTime.new!(DateTime.to_date(dt_updated), DateTime.to_time(dt_updated))

    make_interval_times(dt_naive, Timex.end_of_day(dt_naive), step)
  end

  defp make_interval_times(datetime, end_of_day, step) do
    Timex.Interval.new(from: datetime, until: end_of_day, right_open: false)
    |> Timex.Interval.with_step(minutes: step)
    |> Enum.map(&Timex.format!(&1, "%I:%M %p", :strftime))
  end

  defp minutes_ceil(minute, precision \\ @minutes_step) do
    case precision - rem(minute, precision) do
      0 -> minute
      minutes_left -> minutes_left
    end
  end
end

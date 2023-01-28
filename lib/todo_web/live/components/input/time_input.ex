defmodule TodoWeb.Components.TimeInput do
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
  use TodoWeb, :live_component
  alias Todo.Tempo

  def render(assigns) do
    class =
      class_list([
        {"p-3 bg-blue-700 hover:bg-blue-900 text-blue-900 hover:text-white text-md font-semibold cursor-pointer",
         true}
      ])

    label =
      assigns.field
      |> Atom.to_string()
      |> String.capitalize()

    assigns =
      assigns
      |> assign(class: class)
      |> assign(default_next_day_time: "8:00 AM")
      |> assign(is_label: Map.get(assigns, :label, true))
      |> assign(label: label)

    ~H"""
    <div class="flex flex-col w-full">
        <%= if @is_label do %>
          <label class="text-sm text-blue-900 font-normal"><%= @label %></label>
        <% end %>
        <div class="flex flex-row justify-between border border-gray-300 my-1 items-center rounded-md bg-white px-3 py-3">
          <%= select @form, @field, @times, selected: @default_next_day_time, class: "appearance-none w-full text-blue-900 font-md focus:outline-none focus:ring-blue focus:border-blue focus:z-10 sm:text-sm" %>
          <i><%= Heroicons.icon("clock", type: "solid", class: "h-5 w-5 fill-blue-900") %></i>
        </div>
        <%= error_tag @form, @field %>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def preload([%{selected_date: selected_date, timezone: timezone}] = list_of_assigns) do
    Enum.map(list_of_assigns, fn assign ->
      times =
        selected_date
        |> Tempo.list_of_times(timezone)
        |> Enum.map(&Timex.format!(&1, "%I:%M %p", :strftime))

      Map.put(assign, :times, times)
    end)
  end

  def preload([%{timezone: timezone}] = list_of_assigns) do
    Enum.map(list_of_assigns, fn assign ->
      times =
        Tempo.list_of_times(nil, timezone)
        |> Enum.map(&Timex.format!(&1, "%I:%M %p", :strftime))

      date = DateTime.to_date(Tempo.now!(timezone))

      assign
      |> Map.put(:times, times)
      |> Map.put(:date, date)
    end)
  end
end

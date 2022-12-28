defmodule TodoWeb.Components.TimeInput do
  use TodoWeb, :live_component

  @moduledoc """
          <.live_component module={TodoWeb.Components.TimeInput}
                    id={"day-input"}
                    index={i}
                    current={@current}
                    date={Timex.shift(@beginning_of_month, days: i)}
                    timezone={@timezone}
                    field={@field}
                    form={@form}
                    />

  """
  def render(assigns) do
    times =
      list_of_time(Timex.today())
      |> Enum.map(&Timex.format!(&1, "%I:%M %p", :strftime))

    class =
      class_list([
        {"p-3 bg-blue-700 hover:bg-blue-900 text-blue-900 hover:text-white text-md font-semibold cursor-pointer",
         true}
      ])

    assigns =
      assigns
      |> assign(times: times)
      |> assign(class: class)
      |> assign(label: Map.get(assigns, :label, true))

    ~H"""
    <div class="flex flex-col w-full">
        <%= if @label do %>
          <label class="text-md text-blue-900 font-normal"><%= Atom.to_string(@field) |> String.capitalize %></label>
        <% end %>
        <div class="flex flex-row justify-between border border-gray-300 my-1 items-center rounded-md bg-white px-3 py-3">
          <%= select @form, @field, @times, class: "appearance-none w-full text-blue-900 font-md focus:outline-none focus:ring-blue focus:border-blue focus:z-10 sm:text-sm", phx_update: "ignore" %>
          <i><%= Heroicons.icon("clock", type: "solid", class: "h-5 w-5 fill-blue-900") %></i> 
        </div>
        <%= error_tag @form, @field %>
    </div>
    """
  end

  def mount(socket) do
    socket =
      socket
      |> assign(show_time: false)
      |> assign(selected_time: "")

    {:ok, socket}
  end

  def list_of_time(date) do
    Timex.Interval.new(from: date, until: [days: 1], left_open: false)
    |> Timex.Interval.with_step(minutes: 30)
    |> Enum.map(& &1)
  end
end

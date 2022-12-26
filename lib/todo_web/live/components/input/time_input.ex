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
    times = list_of_time(Timex.today())

    class =
      class_list([
        {"p-3 bg-blue-700 hover:bg-blue-900 text-blue-900 hover:text-white text-md font-semibold cursor-pointer",
         true}
      ])

    assigns =
      assigns
      |> assign(times: times)
      |> assign(class: class)

    ~H"""
    <div class="flex flex-col w-full">
        <label class="text-md text-blue-900 font-normal"><%= Atom.to_string(@field) |> String.capitalize %></label>
        <div class="flex flex-row justify-between border border-gray-300 my-1 items-center rounded-md bg-white px-3 py-3">
          <%= text_input @form, @field, value: @selected_time, placeholder: "00:00 AM", class: "appearance-none w-full text-blue-900 font-md focus:outline-none focus:ring-blue focus:border-blue focus:z-10 sm:text-sm", phx_click: "show-time", phx_target: @myself %>
          <i><%= Heroicons.icon("clock", type: "solid", class: "h-5 w-5 fill-blue-900") %></i> 
        </div>
      <%= if @show_time do %>
        <div class="flex flex-col h-80 w-1/2 bg-white overflow-auto ">
          <%= for time <- @times do %>
            <a class={@class} phx-value-selected-time={Timex.format!(time, "%l:%M %p", :strftime)} phx-click="select-time" phx-target={"##{@form.name}_#{@field}"} >
              <%= Timex.format!(time, "%l:%M %p", :strftime) %> 
            </a> 
        <% end %>
        </div>
      <% end %>
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

  def handle_event("show-time", _, socket) do
    {:noreply, assign(socket, show_time: true)}
  end

  def handle_event("hide-time", _, socket) do
    {:noreply, assign(socket, show_time: false)}
  end

  def handle_event("select-time", %{"selected-time" => time}, socket) do
    socket =
      socket
      |> assign(selected_time: time)
      |> assign(show_time: false)

    {:noreply, socket}
  end

  def list_of_time(date) do
    Timex.Interval.new(from: date, until: [days: 1], left_open: false)
    |> Timex.Interval.with_step(minutes: 30)
    |> Enum.map(& &1)
  end
end

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
  alias Todo.Helpers.Tempo

  @default_next_day_time "8:00 AM"

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
      |> assign(default_next_day_time: @default_next_day_time)
      |> assign(is_label: Map.get(assigns, :label, true))
      |> assign(label: label)

    ~H"""
    <div x-data="{open: false}" @click.away="open = false" class="flex flex-col w-full">
      <div>
        <%= if @is_label do %>
          <label class="block text-sm font-normal text-gray-700"><%= @label %></label>
        <% end %>
        <div class="relative mt-1">
          <%= hidden_input @form, @field, value: @selected_time %>
          <button @click="open = true" type="button" class="relative w-full cursor-default rounded-md border border-gray-300 bg-white py-3 pl-3 pr-10 text-left shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 sm:text-sm" aria-haspopup="listbox" aria-expanded="true" aria-labelledby="listbox-label">
            <span class="flex items-center">
              <span class="ml-3 block truncate"><%= @selected_time %></span>
            </span>
            <span class="pointer-events-none absolute inset-y-0 right-0 ml-3 flex items-center pr-2">  
              <i><%= Heroicons.icon("clock", type: "solid", class: "h-5 w-5 fill-blue-900") %></i>
            </span>
            </button>
            <%= error_tag @form, @field %>
          <ul 
            x-show="open" 
            @click.away="open = false" 
            x-transition:enter="transition ease-out duration-100"
            x-transition:enter-start="transform opacity-0 scale-95"
            x-transition:enter-end="transform opacity-100 scale-100"
            x-transition:leave="transition ease-in duration-75"
            x-transition:leave-start="transform opacity-100 scale-100"
            x-transition:leave-end="transform opacity-0 scale-95"
          class="absolute z-10 mt-1 max-h-56 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm" tabindex="-1" role="listbox" aria-labelledby="listbox-label" aria-activedescendant="listbox-option-3">
              <%= for time <- @times do %>
              <li class={"#{if @selected_time == time, do: "text-white bg-blue-900", else: "text-gray-900"} relative cursor-default select-none py-2 pl-3 pr-9 cursor-pointer"} @click.away="open = false" @click="open = false"  role="option" >
                <div class="flex items-center" phx-target={@myself} phx-click="select-time" phx-value-selected-time={time} >
                  <!-- Selected: "font-semibold", Not Selected: "font-normal" -->
                  <span class="font-normal ml-3 block truncate"  ><%= time %></span>
                </div>
                <%= if @selected_time == time do %>
                <span class={"#{if @selected_time == time, do: "text-white", else: "text-indigo-600"} absolute inset-y-0 right-0 flex items-center pr-4"}>
                  <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                    <path fill-rule="evenodd" d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z" clip-rule="evenodd" />
                  </svg>
                </span>
                <% end %>
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("select-time", %{"selected-time" => selected_time} = _params, socket) do
    {:noreply, assign(socket, :selected_time, selected_time)}
  end

  def preload([%{selected_date: selected_date, timezone: timezone}] = list_of_assigns) do
    Enum.map(list_of_assigns, fn assign ->
      times =
        selected_date
        |> Tempo.list_of_times(timezone)
        |> Enum.map(&Timex.format!(&1, "%I:%M %p", :strftime))

      new_times = times -- assign.booked_schedules

      selected_time = hd(new_times)

      assign
      |> Map.put(:times, new_times)
      |> Map.put(:selected_time, selected_time)
    end)
  end

  def preload([%{timezone: timezone}] = list_of_assigns) do
    Enum.map(list_of_assigns, fn assign ->
      times =
        Tempo.list_of_times(nil, timezone)
        |> Enum.map(&Timex.format!(&1, "%I:%M %p", :strftime))

      new_times = times -- assign.booked_schedules
      selected_time = hd(new_times)
      date = DateTime.to_date(Tempo.now!(timezone))

      assign
      |> Map.put(:times, new_times)
      |> Map.put(:date, date)
      |> Map.put(:selected_time, selected_time)
    end)
  end
end

defmodule TodoWeb.Components do
  use TodoWeb, :component

  def calendar_weeks(
        %{
          current_path: current_path,
          previous_week: previous_week,
          next_week: next_week,
          timezone: timezone
        } = assigns
      ) do
    previous_week_path = build_path(current_path, %{week: previous_week})
    next_week_path = build_path(current_path, %{week: next_week})

    assigns =
      assigns
      |> assign(previous_week_path: previous_week_path)
      |> assign(next_week_path: next_week_path)

    ~H"""
        <div class="flex flex-row px-6 justify-between align-center">
          <%= live_patch to: @previous_week_path do %> 
        <button class="flex items-center justify-center w-10 h-10 text-blue-700 align-middle rounded-full hover:bg-blue-200">
                    <i><%= Heroicons.icon("arrow-circle-left", type: "solid", class: "h-10 w-10 fill-indigo-500") %></i>
        </button>
        <% end %>
            <div class="flex flex-row items-center mb-2 text-gray-500 gap-2">
                <h1 class="my-3 text-xl text-black"><%= Timex.format!(@beginning_of_week, "%B %d", :strftime) %> - <%= Timex.format!(@end_of_week, "%d %Y", :strftime)%></h1>
            </div>
          <%= live_patch to: @next_week_path do %> 
            <button class="flex items-center justify-center w-10 h-10 text-blue-700 align-middle rounded-full hover:bg-blue-200">
                <i><%= Heroicons.icon("arrow-circle-right", type: "solid", class: "h-10 w-10 fill-indigo-500") %></i>
            </button>
        <% end %>
        </div>

        <div class="py-2 px-5 text-center uppercase grid grid-cols-8 gap-2">
          <%= for {date, list_of_time} <- @current_week do %>
              <div class="flex flex-col gap-2">
                <div class="text-md"><%= if date == "time", do: "time", else: Timex.format!(date, "%a %m-%d", :strftime) %></div>
                  <%= for time <- list_of_time do %>
                    <TodoWeb.Components.time
                      date={date}
                      datetime={time}
                      timezone={timezone}
                      current_path={current_path} 
                    />
                  <% end %>
              </div> 
          <% end %>
        </div>
    """
  end

  def calendar_months(
        %{
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
            <div class="flex-1">
                <%= Timex.format!(@current, "%B %Y", :strftime)%> 
            </div>
            <div class="flex justify-end flex-1 text-right">
                <%= live_patch to: @previous_month_path do %>
                    <button class="flex items-center justify-center w-10 h-10 text-blue-700 align-middle rounded-full hover:bg-blue-200">
                        <i><%= Heroicons.icon("arrow-circle-left", type: "solid", class: "h-10 w-10  fill-indigo-500") %></i>
                    </button>
                <% end %>
                <%= live_patch to: @next_month_path do %>
                <button class="flex items-center justify-center w-10 h-10 text-blue-700 align-middle rounded-full hover:bg-blue-200">
                    <i><%= Heroicons.icon("arrow-circle-right", type: "solid", class: "h-10 w-10 fill-indigo-500") %></i>
                </button>
                <% end %>
            </div>
        </div>
        <div class="mb-6 text-center uppercase calendar grid grid-cols-7 gap-y-2 gap-x-2">
            <div class="text-xs">Mon</div>
            <div class="text-xs">Tue</div>
            <div class="text-xs">Wed</div>
            <div class="text-xs">Thu</div>
            <div class="text-xs">Fri</div>
            <div class="text-xs">Sat</div>
            <div class="text-xs">Sun</div>
            <%= for i <- 0..(@end_of_month.day - 1) do %>
                <TodoWeb.Components.day
                    index={i}
                    current_path={Routes.live_path(@socket, TodoWeb.DashboardLive)}
                    date={Timex.shift(@beginning_of_month, days: i)}
                    timezone={@timezone}
                />
            <% end %>
        </div>
        <div class="flex items-center gap-x-1">
            <i><%= Heroicons.icon("globe", type: "solid", class: "h-7 w-7 fill-indigo-500") %></i>
            <%= @timezone %> 
        </div>
    </div>
    """
  end

  def time(
        %{
          current_path: current_path,
          timezone: timezone,
          date: date,
          datetime: datetime
        } = assigns
      ) do
    datetime_path = build_path(current_path, %{datetime: datetime})
    disabled = Timex.compare(datetime, Timex.today(timezone)) == -1
    weekday = Timex.weekday(datetime, :monday)
    pointer = if date == "time", do: "pointer-events-none", else: ""

    class =
      class_list([
        {"w-full h-full p-3 justify-center items-center flex", true},
        {"bg-blue-50 text-blue-600 font-bold hover:bg-blue-200 #{pointer}", not disabled},
        {"text-gray-300 cursor-default pointer-events-none", disabled}
      ])

    text = if date == "time", do: Timex.format!(datetime, "%l:%M %P", :strftime), else: ""

    assigns =
      assigns
      |> assign(disabled: disabled)
      |> assign(text: text)
      |> assign(datetime_path: datetime_path)
      |> assign(class: class)

    ~H"""
    <%= live_patch to: @datetime_path, class: @class, disabled: @disabled  do %>
      <%= @text %> 
      <% end %>
    """
  end

  def day(%{index: index, current_path: current_path, timezone: timezone, date: date} = assigns) do
    date_path = build_path(current_path, %{date: date})
    disabled = Timex.compare(date, Timex.today(timezone)) == -1
    weekday = Timex.weekday(date, :monday)

    class =
      class_list([
        {"grid-column-#{weekday}", index == 0},
        {"content-center w-10 h-10 rounded-full justify-center items-center flex", true},
        {"bg-blue-50 text-blue-600 font-bold hover:bg-blue-200", not disabled},
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

  def nav(assigns) do
    ~H"""
      <!-- This example requires Tailwind CSS v2.0+ -->
      <nav x-data="{ isOpen: false }" class="h-auto w-full bg-gray-800">
        <div class="max-w-7xl mx-auto px-2 sm:px-6 lg:px-8">
          <div class="relative flex items-center justify-between h-16">
            <div class="absolute inset-y-0 left-0 flex items-center sm:hidden">
              <!-- Mobile menu button-->
                <button @click="isOpen = !isOpen "type="button" class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-white hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white" aria-controls="mobile-menu" aria-expanded="false">
                  <span class="sr-only">Open main menu</span>
                  <i><%= Heroicons.icon("menu", type: "outline", class: "block h-6 w-6 mr-1 fill-indigo-500") %></i>
                  <i ><%= Heroicons.icon("x", type: "outline", class: "hidden h-7 w-7 mr-1 fill-indigo-500") %></i>
                </button>
              </div>
              <div class="flex-1 flex items-center justify-center sm:items-stretch sm:justify-start">
                <div class="flex-shrink-0 flex items-center">
                  <i><%= Heroicons.icon("check-circle", type: "solid", class: "h-7 w-7 mr-1 fill-indigo-500") %></i>
                  <a href="/" class="text-2xl font-bold text-indigo-500">gawain</a>
                </div>
                <div class="hidden sm:block sm:ml-6">
                  <div class="flex space-x-4">
                    <!-- Current: "bg-gray-900 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white" -->
                    <%= live_patch "Dashboard",  to: Routes.live_path(@socket, TodoWeb.DashboardLive ), class: "bg-gray-900 text-white px-3 py-2 rounded-md text-sm font-medium"  %>
                    <%= live_patch "Schedule", to: Routes.live_path(@socket, TodoWeb.ScheduleLive ), class: "bg-gray-900 text-white px-3 py-2 rounded-md text-sm font-medium" %>
                </div>
                  </div>
                </div>
                <div class="absolute inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0">
                  <button type="button" class="bg-gray-800 p-1 rounded-full text-gray-400 hover:text-white focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-white">
                    <span class="sr-only">View notifications</span>
                    <!-- Heroicon name: outline/bell -->
                      <i><%= Heroicons.icon("bell", type: "outline", class: "block h-6 w-6 mr-1") %></i>
                    </button>

                    <!-- Profile dropdown -->
                      <div class="ml-3 relative">
                        <div
                          x-data="{
                          open: false,
                          toggle() {
                          if (this.open) {
                          return this.close()
                          }

                          this.$refs.button.focus()

                          this.open = true
                          },
                          close(focusAfter) {
                          if (! this.open) return

                          this.open = false

                          focusAfter && focusAfter.focus()
                          }
                          }"
                          x-on:keydown.escape.prevent.stop="close($refs.button)"
                          x-on:focusin.window="! $refs.panel.contains($event.target) && close()"
                          x-id="['dropdown-button']"
                          class="relative"
                        >
                          <button 
                            x-ref="button"
                            x-on:click="toggle()"
                            :aria-expanded="open"
                            :aria-controls="$id('dropdown-button')"
                            type="button"
                            class="bg-gray-800 flex text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-white" id="user-menu-button" aria-expanded="false" aria-haspopup="true">
                            <span class="sr-only">Open user menu</span>
                            <img class="h-8 w-8 rounded-full" src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80" alt="">
                          </button> 
                            <div
                              x-ref="panel"
                              x-show="open"
                              x-transition.origin.top.left
                              x-on:click.outside="close($refs.button)"
                              :id="$id('dropdown-button')"
                              style="display: none;"
                              class="origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 focus:outline-none" role="menu" aria-orientation="vertical" aria-labelledby="user-menu-button" tabindex="-1">
                <!-- Active: "bg-gray-100", Not Active: "" -->
                <p class="block px-4 py-2 text-sm text-gray-700"><%= @current_user.email %></p>
                <div class="border-2 border-gray-200 border-b-gray-200 mx-1"></div>
                <%= link "Settings", class: "block px-4 py-2 text-sm text-gray-700", to: Routes.user_settings_path(@socket, :edit) %>
                <%= link "Log out", class: "block px-4 py-2 text-sm text-gray-700", to: Routes.user_session_path(@socket, :delete), method: :delete %>
                </div>
                </div>
                </div>
                </div>
                </div>
                </div>

    <!-- Mobile menu, show/hide based on menu state. -->
    <div x-show="isOpen" @click.away="isOpen = false" class="sm:hidden" id="mobile-menu">
    <div class="px-2 pt-2 pb-3 space-y-1">
        <!-- Current: "bg-gray-900 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white" -->
        <a href="#" class="bg-gray-900 text-white block px-3 py-2 rounded-md text-base font-medium" aria-current="page">Dashboard</a>

        <a href="#" class="text-gray-300 hover:bg-gray-700 hover:text-white block px-3 py-2 rounded-md text-base font-medium">Team</a>

        <a href="#" class="text-gray-300 hover:bg-gray-700 hover:text-white block px-3 py-2 rounded-md text-base font-medium">Projects</a>

        <a href="#" class="text-gray-300 hover:bg-gray-700 hover:text-white block px-3 py-2 rounded-md text-base font-medium">Calendar</a>
      </div>
    </div>
    </nav>
    """
  end

  defp build_path(current_path, params) do
    current_path
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(params))
    |> URI.to_string()
  end

  defp class_list(items) do
    items
    |> Enum.reject(&(elem(&1, 1) == false))
    |> Enum.map(&elem(&1, 0))
    |> Enum.join(" ")
  end
end

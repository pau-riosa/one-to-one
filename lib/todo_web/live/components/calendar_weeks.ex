defmodule TodoWeb.Components.CalendarWeeks do
  use TodoWeb, :component

  def calendar_weeks(
        %{
          id: id,
          socket: socket,
          current_path: current_path,
          previous_week: previous_week,
          next_week: next_week,
          timezone: timezone,
          selected_timeslots: selected_timeslots
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
                    />
                  <% end %>
              </div> 
          <% end %>
        </div>
    """
  end
end

defmodule TodoWeb.Components.CalendarMonths do
  use TodoWeb, :component

  @doc """

    <CalendarMonths.calendar_months
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
            <div class="flex-1 text-blue-900">
                <%= Timex.format!(@current, "%B %Y", :strftime)%> 
            </div>
            <div class="flex justify-end flex-1 text-right">
                <%= live_patch to: @previous_month_path do %>
                    <button class="flex items-center justify-center w-10 h-10 text-blue-700 align-middle rounded-full hover:bg-blue-200">
                        <i><%= Heroicons.icon("chevron-left", type: "solid", class: "h-10 w-10  fill-blue-900") %></i>
                    </button>
                <% end %>
                <%= live_patch to: @next_month_path do %>
                <button class="flex items-center justify-center w-10 h-10 text-blue-700 align-middle rounded-full hover:bg-blue-200">
                    <i><%= Heroicons.icon("chevron-right", type: "solid", class: "h-10 w-10 fill-blue-900") %></i>
                </button>
                <% end %>
            </div>
        </div>
        <div class="mb-6 text-center text-blue-900 uppercase calendar grid grid-cols-7 gap-y-2 gap-x-2">
            <div class="text-xs">Mon</div>
            <div class="text-xs">Tue</div>
            <div class="text-xs">Wed</div>
            <div class="text-xs">Thu</div>
            <div class="text-xs">Fri</div>
            <div class="text-xs">Sat</div>
            <div class="text-xs">Sun</div>
            <%= for i <- 0..(@end_of_month.day - 1) do %>
                <TodoWeb.Components.Day.day
                    index={i}
                    current_path={current_path}
                    date={Timex.shift(@beginning_of_month, days: i)}
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
end

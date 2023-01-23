defmodule TodoWeb.Components.DayInput do
  use TodoWeb, :live_component

  @moduledoc """
          <.live_component module={TodoWeb.Components.DayInput}
                    id={"day-input"}
                    index={i}
                    current={@current}
                    date={Timex.shift(@beginning_of_month, days: i)}
                    timezone={@timezone}
                    field={@field}
                    form={@form}
                    />

  """
  def render(
        %{
          index: index,
          timezone: timezone,
          date: date,
          current: current
        } = assigns
      ) do
    disabled = Timex.compare(date, Timex.today(timezone)) == -1
    weekday = Timex.weekday(date, :monday)

    class =
      class_list([
        {"grid-column-#{weekday}", index == 0},
        {"content-center w-10 h-10 rounded-full justify-center items-center flex", true},
        {"bg-blue-900 hover:bg-blue-700 text-white hover:text-blue-900 cursor-pointer font-bold",
         not disabled and current == date},
        {"hover:bg-blue-900 text-blue-900 hover:text-white cursor-pointer font-bold",
         not disabled and current != date},
        {"text-gray-200 cursor-not-allowed", disabled}
      ])

    assigns =
      assigns
      |> assign(disabled: disabled)
      |> assign(text: Timex.format!(date, "{D}"))
      |> assign(class: class)

    ~H"""
    <a class={@class}
    disabled={@disabled}
    {unless @disabled, do: [{:phx, [click: "select-date", value_selected_date: @date, target: "##{@form.name}_#{@field}"]}], else: []}
    >
      <%= @text %>
      </a>
    """
  end
end

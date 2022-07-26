defmodule TodoWeb.Components.Day do
  use TodoWeb, :component

  def day(%{index: index, current_path: current_path, timezone: timezone, date: date} = assigns) do
    date_path = build_path(current_path, %{date: date})
    disabled = Timex.compare(date, Timex.today(timezone)) == -1
    weekday = Timex.weekday(date, :monday)

    class =
      class_list([
        {"grid-column-#{weekday}", index == 0},
        {"content-center w-10 h-10 rounded-full justify-center items-center flex", true},
        {"bg-blue-50 text-blue-900 font-bold hover:bg-yellow-900", not disabled},
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
end

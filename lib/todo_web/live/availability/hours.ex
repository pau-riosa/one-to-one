defmodule TodoWeb.AvailabilityLive.Hours do
  use TodoWeb, :live_component
  alias Todo.Contexts.Availability

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    availability = Availability.for(assigns.current_user).availability_entries
    availability |> IO.inspect(label: "ava")

    ~H"""
    <.day day={:monday} />
    <.day day={:sunday} />
    """
  end

  def day(assigns) do
    ~H"""
    <div class="flex flex-row">
    <div><%= @day %></div>
    <div>Unavailable</div>
    <div>+</div>
    </div>
    """
  end
end

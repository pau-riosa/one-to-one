defmodule TodoWeb.Components.MultiSelectInput do
  use TodoWeb, :live_component

  def render(assigns) do
    ~H"""

    <div>
      <%= text_input @f, @field, placeholder: @placeholder, class: "appearance-none rounded w-full px-3 py-3 my-1 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue focus:border-blue focus:z-10 sm:text-sm", phx_window_keyup: "enter", phx_target: @myself %>
                    <div class="grid grid-cols-6 gap-1"> 
    <%= for item <- @items do %>
                            <div class="flex flex-row">
        <span class="rounded rounded-md bg-gray-300 text-blue-900 p-3 my-3"><%= item %></span> 
      </div>
      <% end %>
      </div>
    </div> 
    """
  end

  @impl true
  def handle_event("enter", %{"key" => "Enter", "value" => value} = _params, socket) do
    {:noreply, assign(socket, :items, [value | socket.assigns.items])}
  end

  def handle_event("enter", _params, socket) do
    {:noreply, socket}
  end

  def mount(socket) do
    {:ok, socket}
  end
end

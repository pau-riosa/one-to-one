defmodule TodoWeb.Components.MultiSelectInput do
  @moduledoc """
  add items in assigns in your parent liveview mount

  def mount(_params, _sesion, socket) do
    ...
    socket = assign(socket, :items, [])
    {:ok, socket}
  end

  add handle_event in your parent liveview

  def handle_event("add-item", item, socket) do
    ...do your thing 
  end

  add handle_info in your parent liveview

  def handle_info({:remove_item, item}, socket) do
    ... do your thing 
  end

  add handle_event in your other live_component


  def handle_event("comma", _params, socket) do

    [value, _] = String.split(value, ",")
    socket =
      socket
      |> assign(:items, [value, socket.assigns.items])

      {:noreply, socket}
  end

  def handle_event("comma", _params, socket) do
  {:noreply, socket} 
  end
  """
  use TodoWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col border border-gray-300 rounded rounded-md p-3 bg-white">
      <div class="wrap-items">
      <%= for item <- @items do %>
        <div class="flex flex-row justify-center  align-center rounded rounded-md text-center bg-gray-300 text-blue-900 p-2 m-1">
        <%= item %>
        <%= Heroicons.icon("x", phx_click: "remove-item", phx_target: @myself, phx_value_item: item, type: "solid", class: "rounded rounded-full border border-red-600 fill-red-700 self-center h-4 w-4 ml-3 cursor-pointer") %>
        </div> 
        <% end %>
    <%= text_input @form, @field, placeholder: @placeholder, class: "flex-1 appearance-none p-1 border border-0 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue focus:border-blue focus:z-10 sm:text-sm ", phx_target: @myself, phx_hook: "CreateItem" %>
      </div> 
    </div> 
    """
  end

  @impl true
  def handle_event("remove-item", %{"item" => item} = _params, socket) do
    send(self(), {:remove_item, item})
    {:noreply, socket}
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end
end

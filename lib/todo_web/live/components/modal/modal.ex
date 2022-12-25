defmodule TodoWeb.Components.Modal do
  use TodoWeb, :live_component

  @moduledoc """
  <.live_component module={TodoWeb.Component.Modal} 
    id="" 
    title="" 
    subtitle="" 
    modal_content_class="" 
    modal_class="">
    
    // put your content here content

  </.live_component>
  """
  @modal_class "!opacity-100 fixed z-100 left-0 top-0 w-full h-full overflow-auto bg-black-rgba "
  @content_class "bg-[#fefefe] mx-auto my-[15vh] p-[20px] border-2 border-blue-700 rounded-md w-5/6"

  def mount(socket) do
    {:ok,
     assign(socket,
       show_modal: false,
       modal_content_class: @content_class,
       modal_class: @modal_class
     )}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("open", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(transition: "fade-out", to: "#modal-#{id}")
    |> JS.hide(transition: "fade-out-scale", to: "#modal-content-#{id}")
    |> JS.push("close", target: "#modal-#{id}")
  end
end

defmodule TodoWeb.Components.Modal do
  use TodoWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, show_modal: false)}
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

defmodule TodoWeb.CreateScheduleLiveComponent do
  use TodoWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end
end

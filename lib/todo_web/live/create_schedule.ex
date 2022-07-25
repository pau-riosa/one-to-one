defmodule TodoWeb.CreateScheduleLiveComponent do
  use TodoWeb, :live_component

  alias Phoenix.LiveView.JS

  @impl true
  def mount(socket) do
    {:ok, socket}
  end
end

defmodule TodoWeb.Components.CreateSession do
  use TodoWeb, :live_component

  @moduledoc """
  <.live_component module={TodoWeb.Components.CreateSession} id="create-session">
  """

  alias Todo.Events.{Event, Operation}

  def mount(socket) do
    changeset = Event.changeset(%Event{}, %{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def handle_event("save", _, socket) do
    {:noreply, socket}
  end
end

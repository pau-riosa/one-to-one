defmodule TodoWeb.Book.BookClass do
  use TodoWeb, :live_component

  alias Todo.Events
  alias Todo.Events.Event
  alias TodoWeb.Components.CalendarMonths

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

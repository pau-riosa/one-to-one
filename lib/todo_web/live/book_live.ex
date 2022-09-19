defmodule TodoWeb.BookLive do
  use TodoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

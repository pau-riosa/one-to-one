defmodule TodoWeb.Components.SideNav do
  use TodoWeb, :live_component

  def update(assigns, socket) do
    public_url = Routes.book_url(socket, :index, assigns.current_user.slug)

    {:ok,
     assign(socket,
       public_url: public_url,
       current_user: assigns.current_user,
       active_tab: assigns.active_tab
     )}
  end
end

defmodule TodoWeb.AvailabilityLive do
  use TodoWeb, :live_view
  alias Todo.Contexts.Availability

  def mount(_params, _session, socket) do
    availability = Availability.for(socket.assigns.current_user)

    {:ok,
     assign(socket,
       view: :availability_hours,
       page_title: "Availability Hours",
       active_url: socket.assigns.active_url,
       availability: availability
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center align-center">
      <div class="w-full max-w-7xl min-h-screen flex flex-row py-5">
        <.live_component module={TodoWeb.Components.SideNav} id="side-nav" active_tab={@active_tab} current_user={@current_user} />
        <div class="w-full flex flex-col rounded-md space-y-8 px-10">
          <div class="flex flex-col w-full space-y-2 pb-7">
            <h1 class="text-2xl text-blue-900 font-bold">Availability</h1>
            <p class="text-blue-800">Each slot defaults to only 15mins, you can change this under booking duration. </p>
            <p class="text-blue-900">In your local timezone <span class="text-md text-blue-900 font-bold"><%= @timezone %></span></p>
          </div>
          <div class="flex flex-row space-x-10 border-b-2">
            <h1 class={"text-md font-semibold mb-3 cursor-pointer #{if @view == :availability_hours, do: "text-blue-900", else: "text-blue-800"}"} phx-click="show-available-hours">Available Hours</h1>
          </div>
          <%= for {day, hours} <- assigns.availability do %>
            <.day user={assigns.current_user} day={day} hours={hours} />
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def day(assigns) do
    ~H"""
    <div class="flex flex-row w-full">
      <div class="w-2/12 font-bold">
        <%= Macro.camelize("#{@day}") %>
      </div>
      <div class="flex flex-col w-3/12">
      <%= if @hours == [] do %>
        <div>Unavailable</div>
      <% else %>
        <%= for {hour_id, %{from: from, to: to}} <- @hours do %>
        <div class="flex flex-row ">
          <div class="border p-2 mb-2 rounded-lg relative">
              <svg phx-click={JS.push("delete-hour", value: %{hour_id: hour_id, day: @day, user: assigns.user})}
              width="20" height="20" style="transform: translate(10px, -10px);" class="absolute top-0 right-0 cursor-pointer" aria-label="failed" viewBox="0 0 16 16" version="1.1" role="img"><path fill="red" fill-rule="evenodd" d="M2.343 13.657A8 8 0 1113.657 2.343 8 8 0 012.343 13.657zM6.03 4.97a.75.75 0 00-1.06 1.06L6.94 8 4.97 9.97a.75.75 0 101.06 1.06L8 9.06l1.97 1.97a.75.75 0 101.06-1.06L9.06 8l1.97-1.97a.75.75 0 10-1.06-1.06L8 6.94 6.03 4.97z"></path></svg>
              <input type="time" value={from} readonly> - <input type="time" value={to} readonly>
            </div>
        </div>
        <% end %>
      <% end %>
      </div>
    </div>
    """
  end

  def handle_event(
        "delete-hour",
        %{"day" => day, "hour_id" => hour_id, "user" => %{"id" => user_id}},
        socket
      ) do
    params = %{hour_id: hour_id, user_id: user_id}

    updated_availability =
      case Availability.delete_hour(params) do
        {:error, :hour_not_found} ->
          socket.assigns.availability

        _hour_id ->
          atom_day = String.to_atom(day)
          atom_hour_id = String.to_atom(hour_id)

          {_val, updated_availability} =
            pop_in(socket.assigns.availability, [atom_day, atom_hour_id])

          updated_availability
      end

    socket = assign(socket, availability: updated_availability)

    {:noreply, socket}
  end

  def handle_event("show-available-hours", _, socket) do
    {:noreply, assign(socket, view: :availability_hours, page_title: "Availability Hours")}
  end
end

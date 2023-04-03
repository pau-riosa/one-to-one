defmodule TodoWeb.AvailabilityLive do
  use TodoWeb, :live_view
  alias Todo.Contexts.Availability

  def mount(_params, _session, socket) do
    # |> IO.inspect(label: "ASD")
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
            <h1 class={"text-md font-semibold mb-3 cursor-pointer #{if @view == :availability_hours, do: "text-blue-900", else: "text-blue-800"}"} phx-click="show-available-hours">Availability Hours</h1>
          </div>

          <div class="flex flex-row w-full overflow-x-scroll">
            <%= for {day, hours} <- @availability do %>
            <div class="flex flex-col px-2 items-center shrink-0 w-[220px] m-2 border rounded-lg shadow-lg">
              <div class="flex justify-center items-center align-middle uppercase py-4 font-bold relative w-full">
                <div class="absolute">
                  <%= day %>
                </div>
                <div class="translate-x-[80px] flex items-center cursor-pointer">
                  <span phx-click={JS.toggle(to: "#input-#{day}", in: "fade-in-scale", out: "fade-out-scale", time: 300)}
                  class="bg-gray-100 text-gray-800 text-xs font-medium mr-2 px-2.5 py-0.5 rounded dark:bg-gray-700 dark:text-gray-200">
                    ADD
                  </span>
                </div>
              </div>

              <form id={"input-#{day}"} phx-submit="add-hour" style="display: none;">
               <div class="border p-2 mb-2 rounded-lg relative">
                  <button class="flex" type="submit">
                    <svg
                    class="absolute top-0 right-0 cursor-pointer translate-x-[10px] -translate-y-[10px]"
                    width="24" height="24" aria-label="failed"
                    viewBox="0 0 24 24" version="1.1" role="img"><path fill="black" fill-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25zm4.28 10.28a.75.75 0 000-1.06l-3-3a.75.75 0 10-1.06 1.06l1.72 1.72H8.25a.75.75 0 000 1.5h5.69l-1.72 1.72a.75.75 0 101.06 1.06l3-3z"></path>
                    </svg>
                  </button>
                 <input id={"input-#{day}-1"} type="time" name="from" value="06:00">
                 -
                 <input id={"input-#{day}-2"} type="time" name="to" value="06:22">
                 <input type="hidden" name="day" value={day} >
                 <input type="hidden" name="user_id" value={assigns.current_user.id} >
               </div>
             </form>

              <%= for %{id: id, from: from, to: to} <- hours do %>
              <div class="border p-2 mb-2 rounded-lg relative">
                <svg phx-click={JS.push("delete-hour", value: %{hour_id: id, day: day, user: assigns.current_user})}
                class="absolute top-0 right-0 cursor-pointer translate-x-[10px] -translate-y-[10px]"
                width="20" height="20" aria-label="failed" viewBox="0 0 16 16" version="1.1" role="img"><path fill="red" fill-rule="evenodd" d="M2.343 13.657A8 8 0 1113.657 2.343 8 8 0 012.343 13.657zM6.03 4.97a.75.75 0 00-1.06 1.06L6.94 8 4.97 9.97a.75.75 0 101.06 1.06L8 9.06l1.97 1.97a.75.75 0 101.06-1.06L9.06 8l1.97-1.97a.75.75 0 10-1.06-1.06L8 6.94 6.03 4.97z"></path>
                </svg>
                <input type="time" value={from} readonly> - <input type="time" value={to} readonly>
              </div>
              <% end %>
            </div>
            <% end %>
          </div>

        </div>
      </div>
    </div>
    """
  end

  def handle_event(
        "add-hour",
        %{"day" => day, "from" => from, "to" => to, "user_id" => user_id},
        socket
      ) do
    atom_day = String.to_existing_atom(day)
    hours = socket.assigns.availability[atom_day]
    from_timeish = Time.from_iso8601!("#{from}:00")
    to_timeish = Time.from_iso8601!("#{to}:00")

    socket =
      with :lt <- Time.compare(from_timeish, to_timeish),
           :ok <- Availability.check_ovelaps(from_timeish, to_timeish, hours),
           {:ok, _hour} <- Availability.insert_hour(from_timeish, to_timeish, day, user_id) do
        :ok
      else
        diff when diff in [:eq, :gt] -> :add_more_time
        :error_overlap -> :error_overlaps
      end
      |> case do
        :ok -> assign(socket, availability: Availability.for(socket.assigns.current_user))
        _some_error -> socket
      end

    {:noreply, socket}
  end

  def handle_event(
        "delete-hour",
        %{"day" => day, "hour_id" => hour_id, "user" => %{"id" => user_id}},
        socket
      ) do
    params = %{hour_id: hour_id, user_id: user_id}

    new_availability =
      case Availability.delete_hour(params) do
        {:error, _error} ->
          socket.assigns.availability

        availability_hour ->
          atom_day = String.to_existing_atom(day)

          updated_hours_for_day =
            Enum.reject(socket.assigns.availability[atom_day], &(&1.id == availability_hour.id))

          Keyword.replace(socket.assigns.availability, atom_day, updated_hours_for_day)
      end

    socket = assign(socket, availability: new_availability)

    {:noreply, socket}
  end
end

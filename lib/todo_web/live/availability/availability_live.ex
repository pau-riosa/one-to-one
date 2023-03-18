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
    <div class="flex flex-row w-96">
      <div class="w-1/12 font-bold pt-2 mr-5">
        <%= Macro.camelize("#{@day}") %>
      </div>
      <div class="flex flex-col w-full">
        <%= for {hour_id, %{from: from, to: to}} <- @hours do %>
        <div class="flex flex-row justify-center">
          <div class="border p-2 mb-2 rounded-lg relative">
              <svg phx-click={JS.push("delete-hour", value: %{hour_id: hour_id, day: @day, user: assigns.user})}
              width="20" height="20" style="transform: translate(10px, -10px);" class="absolute top-0 right-0 cursor-pointer" aria-label="failed" viewBox="0 0 16 16" version="1.1" role="img"><path fill="red" fill-rule="evenodd" d="M2.343 13.657A8 8 0 1113.657 2.343 8 8 0 012.343 13.657zM6.03 4.97a.75.75 0 00-1.06 1.06L6.94 8 4.97 9.97a.75.75 0 101.06 1.06L8 9.06l1.97 1.97a.75.75 0 101.06-1.06L9.06 8l1.97-1.97a.75.75 0 10-1.06-1.06L8 6.94 6.03 4.97z"></path>
              </svg>
              <input type="time" value={from} readonly> - <input type="time" value={to} readonly>
          </div>
        </div>
        <% end %>
        <div class="relative">
          <div id={"modal-#{@day}"} style="width: 190px; margin-left: auto; margin-right: auto; display: none;">
            <form phx-submit="add-hour">
              <div class="border p-2 mb-2 rounded-lg relative">
              <button class="flex" type="submit">
                <svg
                width="24" height="24" style="transform: translate(10px, -10px);" class="absolute top-0 right-0 cursor-pointer" aria-label="failed"
                viewBox="0 0 24 24" version="1.1" role="img"><path fill="black" fill-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25zm4.28 10.28a.75.75 0 000-1.06l-3-3a.75.75 0 10-1.06 1.06l1.72 1.72H8.25a.75.75 0 000 1.5h5.69l-1.72 1.72a.75.75 0 101.06 1.06l3-3z"></path>
                </svg>
                </button>
                <input id={"input-#{@day}-1"} type="time" name="from" value="06:00">
                -
                <input id={"input-#{@day}-2"} type="time" name="to" value="06:22">
                <input type="hidden" name="day" value={@day} >
                <input type="hidden" name="user_id" value={@user.id} >
              </div>
            </form>
          </div>
        </div>
        <div class="flex justify-center ">
          <button phx-click={JS.toggle(to: "#modal-#{@day}")}
          type="button"
          class="w-24 text-center inline-block rounded bg-neutral-800 px-6 pt-2.5 pb-2 text-sm font-medium uppercase leading-normal text-neutral-50 shadow-[0_4px_9px_-4px_#332d2d] transition duration-150 ease-in-out hover:bg-neutral-800 hover:shadow-[0_8px_9px_-4px_rgba(51,45,45,0.3),0_4px_18px_0_rgba(51,45,45,0.2)] focus:bg-neutral-800 focus:shadow-[0_8px_9px_-4px_rgba(51,45,45,0.3),0_4px_18px_0_rgba(51,45,45,0.2)] focus:outline-none focus:ring-0 active:bg-neutral-900 active:shadow-[0_8px_9px_-4px_rgba(51,45,45,0.3),0_4px_18px_0_rgba(51,45,45,0.2)] dark:bg-neutral-900 dark:shadow-[0_4px_9px_-4px_#171717] dark:hover:bg-neutral-900 dark:hover:shadow-[0_8px_9px_-4px_rgba(27,27,27,0.3),0_4px_18px_0_rgba(27,27,27,0.2)] dark:focus:bg-neutral-900 dark:focus:shadow-[0_8px_9px_-4px_rgba(27,27,27,0.3),0_4px_18px_0_rgba(27,27,27,0.2)] dark:active:bg-neutral-900 dark:active:shadow-[0_8px_9px_-4px_rgba(27,27,27,0.3),0_4px_18px_0_rgba(27,27,27,0.2)]">
            ADD
          </button>
        </div>
      </div>
    </div>
    <div class="w-96"><hr></div>
    """
  end

  def handle_event(
        "add-hour",
        %{"day" => day, "from" => from, "to" => to, "user_id" => user_id},
        socket
      ) do
    atom_day = String.to_atom(day)
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
        :error -> :error_overlaps
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

        hour ->
          atom_day = String.to_atom(day)
          atom_hour_id = String.to_atom(hour.id)

          {_val, updated_availability} =
            pop_in(socket.assigns.availability, [atom_day, atom_hour_id])

          updated_availability
      end

    socket = assign(socket, availability: new_availability)

    {:noreply, socket}
  end

  def handle_event("show-available-hours", _, socket) do
    {:noreply, assign(socket, view: :availability_hours, page_title: "Availability Hours")}
  end
end

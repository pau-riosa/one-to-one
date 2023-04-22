defmodule TodoWeb.Components.CreateSession do
  use TodoWeb, :live_component

  @moduledoc """
  <.live_component module={TodoWeb.Components.CreateSession} id="create-session" timezone={@timezone} current_user={@current_user} active_url={@active_url} />
  """
  alias Todo.Schemas.Schedule
  alias Todo.Operations.Schedule, as: Operation
  alias Todo.Schedules

  def update(assigns, socket) do
    changeset = Operation.changeset(%Schedule{})

    booked_schedules =
      Schedules.get_schedules_by_created_by_id(assigns.current_user.id)
      |> Enum.map(
        &(&1.scheduled_for
          |> Timex.to_datetime(assigns.timezone)
          |> Timex.format!("%I:%M %p", :strftime))
      )

    {:ok,
     socket
     |> assign(:current_user, assigns.current_user)
     |> assign(:timezone, assigns.timezone)
     |> assign(:changeset, changeset)
     |> assign(:active_url, assigns.active_url)
     |> assign(:booked_schedules, booked_schedules)}
  end

  def handle_event("validate", %{"schedule" => schedule_params} = _params, socket) do
    changeset =
      %Schedule{}
      |> Operation.changeset(schedule_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"schedule" => schedule_params} = _params, socket) do
    with schedule_params <- insert_scheduled_for(schedule_params),
         {:ok, %Schedule{} = _schedule} <- Operation.prepare_session(schedule_params, socket) do
      TodoWeb.Endpoint.broadcast("update_booked_schedules", "update", %{"reload" => true})

      {:noreply,
       socket
       |> put_flash(:info, "Schedule created.")
       |> push_redirect(to: socket.assigns.active_url)}
    else
      {:error, :date_and_time_required} ->
        {:noreply,
         socket
         |> put_flash(:error, "Date and time is required.")
         |> push_redirect(to: socket.assigns.active_url)}

      {:error, :email_cannot_be_the_same} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid invitee email.")
         |> push_redirect(to: socket.assigns.active_url)}

      {:error, :cannot_create_participant} ->
        {:noreply,
         socket
         |> put_flash(:error, "Cannot create participant.")
         |> push_redirect(to: socket.assigns.active_url)}

      {:error, :cannot_create_meeting} ->
        {:noreply,
         socket
         |> put_flash(:error, "Cannot create meeting.")
         |> push_redirect(to: socket.assigns.active_url)}

      {:error, _, changeset, _} ->
        {:noreply, assign(socket, :changeset, changeset)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}

      _errors ->
        {:noreply, socket}
    end
  end

  defp insert_scheduled_for(%{"date" => date, "time" => time, "timezone" => timezone} = params) do
    case Timex.parse("#{date} #{time}", "{YYYY}-{0M}-{0D} {h12}:{m} {AM}") do
      {:ok, datetime} ->
        datetime = datetime |> Timex.to_datetime(timezone)
        {:ok, datetime} = Ecto.Type.cast(:utc_datetime_usec, datetime)
        Map.put(params, "scheduled_for", datetime)

      _ ->
        params
    end
  end

  defp insert_scheduled_for(_params), do: {:error, :date_and_time_required}
end

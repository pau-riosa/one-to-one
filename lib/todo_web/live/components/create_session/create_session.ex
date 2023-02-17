defmodule TodoWeb.Components.CreateSession do
  use TodoWeb, :live_component

  @moduledoc """
  <.live_component module={TodoWeb.Components.CreateSession} id="create-session" timezone={@timezone} current_user={@current_user} active_url={@active_url} />
  """
  alias Todo.Helpers.UserNotifier
  alias Todo.Schemas.Schedule
  alias Ecto.Multi

  def update(assigns, socket) do
    changeset = Schedule.changeset(%Schedule{})

    {:ok,
     socket
     |> assign(:current_user, assigns.current_user)
     |> assign(:timezone, assigns.timezone)
     |> assign(:changeset, changeset)
     |> assign(:active_url, assigns.active_url)}
  end

  def handle_event("validate", %{"schedule" => schedule} = _params, socket) do
    changeset =
      Schedule.changeset(%Schedule{}, schedule)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"schedule" => schedule_params} = _params, socket) do
    case prepare_meeting(schedule_params) do
      {:ok, %{create_schedule: schedule, participant: participant}} ->
        schedule = schedule |> Todo.Repo.preload(:created_by)

        UserNotifier.deliver_schedule_instructions(
          schedule,
          TodoWeb.Router.Helpers.url(socket) <>
            Routes.room_path(
              socket,
              :index,
              schedule.id,
              participant.participant_id,
              participant.meeting_id
            )
        )

        {:noreply,
         socket
         |> put_flash(:info, "Schedule created.")
         |> push_redirect(to: socket.assigns.active_url)}

      {:error, _, :cannot_create_meeting, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Cannot create meeting.")
         |> push_redirect(to: socket.assigns.active_url)}

      {:error, _, :cannot_create_participant, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Cannot create participant.")
         |> push_redirect(to: socket.assigns.active_url)}

      _ ->
        {:noreply, socket}
    end
  end

  defp prepare_meeting(schedule_params) do
    Multi.new()
    |> Multi.run(:create_schedule, fn repo, _ ->
      Todo.Operations.Schedule.create_schedule(schedule_params, repo)
    end)
    |> Multi.run(:create_meeting, fn repo, %{create_schedule: schedule} ->
      Todo.Operations.Meeting.create_dyte_meeting(schedule, repo)
    end)
    # create meeting owner to assure that unique email_meeting_id will be inserted 
    # and will not be duplicated upon email invite
    |> Multi.run(:meeting_owner, fn repo,
                                    %{
                                      create_meeting: meeting,
                                      create_schedule: schedule
                                    } ->
      schedule = schedule |> repo.preload(:created_by)

      Todo.Operations.Participant.create_dyte_participant(
        %{
          schedule: schedule,
          email: schedule.created_by.email,
          meeting_id: meeting.meeting_id,
          participant_name: "#{schedule.created_by.first_name} #{schedule.created_by.last_name}",
          preset_name: "basic-version-1"
        },
        repo
      )
    end)
    |> Multi.run(:participant, fn repo,
                                  %{
                                    create_meeting: meeting,
                                    create_schedule: schedule
                                  } ->
      schedule = schedule |> repo.preload(:created_by)

      Todo.Operations.Participant.create_dyte_participant(
        %{
          schedule: schedule,
          email: schedule_params["email"],
          meeting_id: meeting.meeting_id,
          participant_name: schedule_params["name"],
          preset_name: "basic-version-1"
        },
        repo
      )
    end)
    |> Todo.Repo.transaction()
  end
end

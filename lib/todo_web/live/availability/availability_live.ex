defmodule TodoWeb.AvailabilityLive do
  use TodoWeb, :live_view

  alias Todo.Accounts.User
  alias Todo.SessionSetting

  @session_settings [
    %SessionSetting{day: "Sunday"},
    %SessionSetting{day: "Monday"},
    %SessionSetting{day: "Tuesday"},
    %SessionSetting{day: "Wednesday"},
    %SessionSetting{day: "Thursday"},
    %SessionSetting{day: "Friday"},
    %SessionSetting{day: "Saturday"}
  ]

  def mount(_params, _session, socket) do
    current_user =
      socket.assigns.current_user
      |> Todo.Repo.preload(:session_settings)

    settings =
      if Enum.empty?(current_user.session_settings) do
        @session_settings
      else
        current_user.session_settings
      end

    account_changeset =
      current_user
      |> User.availability_changeset()
      |> Ecto.Changeset.put_assoc(
        :session_settings,
        settings
      )

    socket =
      socket
      |> assign(account_changeset: account_changeset)

    {:ok, socket}
  end

  def handle_event("save", %{"user" => user} = _params, socket) do
    changeset =
      socket.assigns.account_changeset
      |> User.availability_changeset(user)
      |> Map.put(:action, :update)
      |> Todo.Repo.update()

    {:noreply, socket}
  end

  def handle_event("validate", %{"user" => user} = _params, socket) do
    socket =
      update(socket, :account_changeset, fn changeset ->
        IO.inspect(user)

        changeset
        |> User.availability_changeset(user)
        |> Map.put(:action, :validate)
      end)

    {:noreply, push_patch(socket, to: Routes.availability_path(socket, :index))}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_event("add-time", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :account_changeset, fn account_changeset ->
        {selected_setting, existing_settings} =
          account_changeset
          |> Ecto.Changeset.get_field(:session_settings, @session_settings)
          |> List.pop_at(index)

        changeset = SessionSetting.changeset(selected_setting)

        existing =
          Ecto.Changeset.get_field(changeset, :times, [])
          |> Enum.map(&Map.put(&1, :id, Ecto.UUID.generate()))

        changeset = Ecto.Changeset.put_embed(changeset, :times, existing ++ [%Todo.Time{}])

        Ecto.Changeset.put_assoc(
          account_changeset,
          :session_settings,
          List.insert_at(existing_settings, index, changeset)
        )
        |> Map.put(:action, :update)
        |> Todo.Repo.update()

        Ecto.Changeset.put_assoc(
          account_changeset,
          :session_settings,
          List.insert_at(existing_settings, index, changeset)
        )
      end)

    {:noreply, socket}
  end

  def handle_event("delete-time", %{"schedule-index" => schedule_index, "index" => index}, socket) do
    schedule_index = String.to_integer(schedule_index)
    index = String.to_integer(index)

    socket =
      update(socket, :account_changeset, fn account_changeset ->
        {selected_setting, existing_settings} =
          account_changeset
          |> Ecto.Changeset.get_field(:session_settings, @session_settings)
          |> List.pop_at(schedule_index)

        changeset = SessionSetting.changeset(selected_setting)
        existing = Ecto.Changeset.get_field(changeset, :times, [])
        changeset = Ecto.Changeset.put_embed(changeset, :times, List.delete_at(existing, index))

        Ecto.Changeset.put_assoc(
          account_changeset,
          :session_settings,
          List.insert_at(existing_settings, schedule_index, changeset)
        )
        |> Map.put(:action, :update)
        |> Todo.Repo.update()

        Ecto.Changeset.put_assoc(
          account_changeset,
          :session_settings,
          List.insert_at(existing_settings, schedule_index, changeset)
        )
      end)

    {:noreply, push_redirect(socket, to: Routes.availability_path(socket, :index))}
  end

  def sorter("Sunday"), do: 0
  def sorter("Monday"), do: 1
  def sorter("Tuesday"), do: 2
  def sorter("Wednesday"), do: 3
  def sorter("Thursday"), do: 4
  def sorter("Friday"), do: 5
  def sorter("Saturday"), do: 6
end

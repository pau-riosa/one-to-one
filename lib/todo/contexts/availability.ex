defmodule Todo.Contexts.Availability do
  import Ecto.Query, warn: false
  alias Todo.Repo
  alias Todo.Schemas.AvailabilityHour
  alias Todo.Schemas.AvailabilityDay
  alias Todo.Schemas.User

  def for(%User{id: id} = _user) do
    days =
      from(u in User,
        join: ad in assoc(u, :availability_days),
        join: ah in assoc(ad, :availability_hours),
        where: u.id == ^id,
        order_by: [asc: ah.from],
        select: {ad.day, %{id: ah.id, from: ah.from, to: ah.to}}
      )
      |> Repo.all()
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    Enum.reduce(DayEnum.__enum_map__(), [], fn day, acc ->
      if day in Map.keys(days),
        do: [{day, Map.get(days, day)} | acc],
        else: [{day, []} | acc]
    end)
    |> Enum.reverse()
  end

  def delete_hour(%{hour_id: hour_id, user_id: user_id}) do
    with %AvailabilityHour{} = hour <- fetch_hour_by_user(hour_id, user_id),
         {:ok, hour} <- Repo.delete(hour) do
      day =
        Repo.get(AvailabilityDay, hour.availability_day_id) |> Repo.preload(:availability_hours)

      hours_size = length(Map.get(day, :availability_hours))

      if hours_size == 0, do: Repo.delete(day)

      hour
    else
      nil -> {:error, :hour_not_found}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp fetch_hour_by_user(hour_id, user_id) do
    from(ah in AvailabilityHour,
      join: ad in AvailabilityDay,
      on: ad.id == ah.availability_day_id,
      join: u in User,
      on: u.id == ad.user_id,
      where: u.id == ^user_id and ah.id == ^hour_id
    )
    |> Repo.one()
  end

  def check_ovelaps(from, to, other_hours) do
    input_interval = Timex.Interval.new(from: time_to_datetime(from), until: time_to_datetime(to))

    Enum.map(other_hours, fn %{from: from, to: to} ->
      hour = Timex.Interval.new(from: time_to_datetime(from), until: time_to_datetime(to))
      Timex.Interval.overlaps?(hour, input_interval)
    end)
    |> Enum.any?()
    |> case do
      true -> :error_overlap
      false -> :ok
    end
  end

  defp time_to_datetime(time) do
    Timex.to_datetime({{2015, 1, 1}, {time.hour, time.minute, 0}}, "Etc/UTC")
  end

  def insert_hour(from, to, day, user_id) do
    from(u in User,
      join: ad in assoc(u, :availability_days),
      where: u.id == ^user_id and ad.day == ^day,
      select: ad
    )
    |> Repo.one()
    |> case do
      nil ->
        AvailabilityDay.changeset(%AvailabilityDay{}, %{
          day: day,
          user_id: user_id,
          availability_hours: [%{from: from, to: to}]
        })

      availability_day ->
        Ecto.build_assoc(availability_day, :availability_hours, %{from: from, to: to})
    end
    |> Repo.insert()
  end
end

defmodule Todo.Contexts.Availability do
  import Ecto.Query, warn: false
  alias Todo.Repo
  alias Todo.Schemas.{AvailabilityEntry, Hour, User}

  def for(%User{id: id} = _user) do
    # Maybe change for something like:
    # https://stackoverflow.com/questions/60028111/nested-json-aggregation-in-postgres
    # https://chrisguitarguy.com/2020/05/12/postgresql-row-to-json-json-agg-json-columns/
    days =
      from(u in User,
        join: ae in assoc(u, :availability_entries),
        join: h in assoc(ae, :hours),
        where: u.id == ^id,
        order_by: [asc: h.from],
        select: {ae.day, %{h.id => %{from: h.from, to: h.to}}}
      )
      |> Repo.all()
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.reduce(%{}, fn {day, hours}, acc ->
        hours =
          Enum.reduce(hours, [], fn val, acc_2 ->
            [{key, value}] = Map.to_list(val)
            [{:"#{key}", value} | acc_2]
          end)
          |> Enum.reverse()

        Map.put_new(acc, day, hours)
      end)

    map =
      Enum.reduce(AvailabilityDayEnum.__enum_map__(), days, fn x, acc ->
        Map.put_new(acc, x, [])
      end)

    for day <- AvailabilityDayEnum.__enum_map__() do
      {day, map[day]}
    end
  end

  def delete_hour(%{hour_id: hour_id, user_id: user_id}) do
    with %Hour{} = hour <- fetch_hour_by_user(hour_id, user_id),
         {:ok, hour} <- Repo.delete(hour) do
      hour
    else
      nil -> {:error, :hour_not_found}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def insert_hour(from, to, day, user_id) do
    from(u in User,
      join: ae in assoc(u, :availability_entries),
      where: u.id == ^user_id and ae.day == ^day,
      select: ae
    )
    |> Repo.one()
    |> case do
      nil ->
        AvailabilityEntry.changeset(%AvailabilityEntry{}, %{
          day: day,
          user_id: user_id,
          hours: [%{from: from, to: to}]
        })

      availability_entry ->
        Ecto.build_assoc(availability_entry, :hours, %{from: from, to: to})
    end
    |> Repo.insert()
  end

  def check_ovelaps(from, to, other_hours) do
    {from, to, other_hours} |> IO.inspect(label: "from, to, other_hours")
    input_interval = Timex.Interval.new(from: time_to_datetime(from), until: time_to_datetime(to))

    Enum.map(other_hours, fn {_k, %{from: from, to: to}} ->
      hour = Timex.Interval.new(from: time_to_datetime(from), until: time_to_datetime(to))

      Timex.Interval.overlaps?(hour, input_interval)
    end)
    |> Enum.any?()
    |> case do
      true -> :error
      false -> :ok
    end
  end

  defp time_to_datetime(time) do
    Timex.to_datetime({{2015, 1, 1}, {time.hour, time.minute, 0}}, "Etc/UTC")
  end

  # def refresh_hours(availability_entry_id) do
  #   from(ae in AvailabilityEntry,
  #     join: h in assoc(ae, :hours),
  #     where: ae.id == ^availability_entry_id,
  #     order_by: [asc: h.from],
  #     select: h
  #   )
  #   |> Repo.all()
  # end

  defp fetch_hour_by_user(hour_id, user_id) do
    from(h in Hour,
      join: ae in AvailabilityEntry,
      on: ae.id == h.availability_entry_id,
      join: u in User,
      on: u.id == ae.user_id,
      where: u.id == ^user_id and h.id == ^hour_id
    )
    |> Repo.one()
  end
end

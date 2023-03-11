defmodule Todo.Contexts.Availability do
  import Ecto.Query, warn: false
  alias Todo.Repo
  alias Todo.Schemas.{AvailabilityEntry, Hour, User}

  def for(%User{id: id} = _user) do
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

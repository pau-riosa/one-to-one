defmodule Todo.Contexts.Availability do
  import Ecto.Query, warn: false
  alias Todo.Schemas.AvailabilityDay
  alias Todo.Repo
  alias Todo.Schemas.AvailabilityHour
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
end

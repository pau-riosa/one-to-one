defmodule Todo.Schemas.AvailabilityDayTest do
  use Todo.DataCase
  alias Todo.Schemas.AvailabilityDay

  @string_days DayEnum.__valid_values__() |> Enum.filter(&is_atom/1)

  test "insert" do
    random_day = Enum.random(@string_days)

    user = insert(:user)

    params = %{day: random_day, user_id: user.id}

    availability_day =
      %AvailabilityDay{}
      |> AvailabilityDay.changeset(params)
      |> Repo.insert!()

    assert availability_day.day == random_day
    assert availability_day.user_id == user.id
  end
end

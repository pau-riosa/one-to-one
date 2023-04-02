defmodule Todo.Schemas.AvailabilityHourTest do
  use Todo.DataCase
  alias Todo.Schemas.AvailabilityHour


  test "insert" do
    now = Time.utc_now() |> Time.truncate(:second)
    later = Time.add(now, 3600, :second) |> Time.truncate(:second)

    availability_day = insert(:availability_day)

    params = %{from: now, to: later, availability_day_id: availability_day.id}

    changeset = AvailabilityHour.changeset(%AvailabilityHour{}, params)

    assert changeset.valid?

    availability_hour = Repo.insert!(changeset)

    assert availability_hour.from == now
    assert availability_hour.to == later
    assert availability_hour.availability_day_id == availability_day.id
  end
end

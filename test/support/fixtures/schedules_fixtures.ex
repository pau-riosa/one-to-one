defmodule Todo.SchedulesFixtures do
  alias Todo.AccountsFixtures

  def unique_email, do: "user#{System.unique_integer()}@example.com"

  def valid_schedule_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "random name",
      email: unique_email(),
      scheduled_for: Timex.now(),
      created_by_id: AccountsFixtures.user_fixture().id,
      duration: 0
    })
  end

  def schedule_fixture(attrs \\ %{}) do
    {:ok, schedule} =
      attrs
      |> valid_schedule_attrs()
      |> Todo.Operations.Schedule.create_schedule()

    schedule
  end
end

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Todo.Repo.insert!(%Todo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Todo.Schemas.User
alias Todo.Repo
alias Todo.Schemas.{AvailabilityDay, AvailabilityHour, User}

params = %{
  first_name: "admin",
  last_name: "admin",
  email: "admin@todo.com",
  password: "password!123!"
}

user =
  %User{}
  |> User.registration_changeset(params)
  |> Repo.insert!()

%AvailabilityDay{
  id: Ecto.UUID.generate(),
  user_id: user.id,
  day: :sunday,
  availability_hours: [
    %AvailabilityHour{
      id: Ecto.UUID.generate(),
      from: ~T[09:00:00],
      to: ~T[09:30:00]
    },
    %AvailabilityHour{
      id: Ecto.UUID.generate(),
      from: ~T[08:00:00],
      to: ~T[08:30:00]
    }
  ]
}
|> Repo.insert!()

%AvailabilityDay{
  id: Ecto.UUID.generate(),
  user_id: user.id,
  day: :monday,
  availability_hours: [
    %AvailabilityHour{
      id: Ecto.UUID.generate(),
      from: ~T[07:00:00],
      to: ~T[07:30:00]
    },
    %AvailabilityHour{
      id: Ecto.UUID.generate(),
      from: ~T[08:00:00],
      to: ~T[08:30:00]
    },
    %AvailabilityHour{
      id: Ecto.UUID.generate(),
      from: ~T[09:00:00],
      to: ~T[09:30:00]
    },
    %AvailabilityHour{
      id: Ecto.UUID.generate(),
      from: ~T[10:00:00],
      to: ~T[10:30:00]
    },
    %AvailabilityHour{
      id: Ecto.UUID.generate(),
      from: ~T[11:00:00],
      to: ~T[11:30:00]
    },
    %AvailabilityHour{
      id: Ecto.UUID.generate(),
      from: ~T[12:00:00],
      to: ~T[12:30:00]
    }
  ]
}
|> Repo.insert!()

# %User{}
# |> User.registration_changeset(params)
# |> Repo.insert!()

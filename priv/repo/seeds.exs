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
alias Todo.Accounts.User
alias Todo.Repo

params = %{
  first_name: "admin",
  last_name: "admin",
  email: "admin@todo.com",
  password: "password!123!"
}

%User{}
|> User.registration_changeset(params)
|> Repo.insert!()

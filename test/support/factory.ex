defmodule Todo.Factory do
  use ExMachina.Ecto, repo: Todo.Repo
  alias Todo.Schemas.{AvailabilityEntry, User}

  import Bcrypt, only: [hash_pwd_salt: 1]

  @account_password "123456789123456789"

  def user_factory() do
    %User{
      email: sequence(:email, &"tester#{&1}@todo.com"),
      hashed_password: hash_pwd_salt(@account_password)
    }
  end

  def availability_entry() do
    %AvailabilityEntry{
      day: Enum.random(AvailabilityDayEnum),
      user: build(:user)
    }
  end
end

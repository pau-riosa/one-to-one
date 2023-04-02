defmodule Todo.Factory do
  use ExMachina.Ecto, repo: Todo.Repo
  alias Todo.Schemas.{AvailabilityDay, User}

  import Bcrypt, only: [hash_pwd_salt: 1]

  @account_password "123456789123456789"

  def user_factory() do
    %User{
      email: sequence(:email, &"tester#{&1}@todo.com"),
      hashed_password: hash_pwd_salt(@account_password)
    }
  end

  def availability_day_factory() do
    %AvailabilityDay{
      day: Enum.random(DayEnum.__valid_values__()),
      user: build(:user)
    }
  end
end

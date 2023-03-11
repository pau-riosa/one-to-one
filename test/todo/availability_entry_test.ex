defmodule Todo.Test.AvailabilityEntrTest do
  use Todo.DataCase
  import Todo.Factory

  describe "" do
    test "" do
      user = insert(:user)
      user |> IO.inspect(label: "user")
    end
  end
end

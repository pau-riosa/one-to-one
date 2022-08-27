defmodule TodoWeb.Presence do
  use Phoenix.Presence,
    otp_app: :todo,
    pubsub_server: Todo.PubSub,
    presence: __MODULE__
end

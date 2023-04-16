# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :todo,
  ecto_repos: [Todo.Repo]

# Configures the endpoint
config :todo, TodoWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: TodoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Todo.PubSub,
  live_view: [signing_salt: "ugzWT0/I"]

# Configures Dyte
config :todo, :dyte,
  org_id: System.get_env("DYTE_ORG_ID"),
  api_key: System.get_env("DYTE_API_KEY")

config :google_calendar, :base_url, "https://www.googleapis.com/calendar/v3"
config :google_calendar, :content_type, [{"content-type", "application/json"}]

config :google_calendar, Google,
  client_id: System.get_env("GOOGLE_CALENDAR_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CALENDAR_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_CALENDAR_REDIRECT_URI")

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :todo, Todo.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.jsx --bundle --target=es2017  --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :todo, TodoWeb.Endpoint, pubsub_server: Todo.PubSub

config :todo, version: System.get_env("VERSION", "unknown")

config :logger, :console, metadata: [:room, :peer]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

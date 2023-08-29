# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixirconf_chat,
  ecto_repos: [ElixirconfChat.Repo]

# Configures the endpoint
config :elixirconf_chat, ElixirconfChatWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: ElixirconfChatWeb.ErrorHTML, json: ElixirconfChatWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ElixirconfChat.PubSub,
  live_view: [signing_salt: "zXGftF2q"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.

if System.get_env("ELIXIRCONF_CHAT_SENDGRID_API_KEY") do
  config :elixirconf_chat, ElixirconfChat.Mailer,
    adapter: Swoosh.Adapters.Sendgrid,
    api_key: System.get_env("ELIXIRCONF_CHAT_SENDGRID_API_KEY", "SG.x.x")

  config :swoosh, :api_client, Swoosh.ApiClient.Hackney
else
  config :elixirconf_chat, ElixirconfChat.Mailer,
    adapter: Swoosh.Adapters.Local

  config :swoosh, :api_client, Swoosh.ApiClient.Local
end

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Define platform support for LiveView Native
config :live_view_native,
  plugins: [
    LiveViewNativeSwiftUi
  ]

# Use Oban for background job processing
config :elixirconf_chat, Oban,
  repo: ElixirconfChat.Repo,
  plugins: [
    Oban.Plugins.Pruner,
    {Oban.Plugins.Cron,
     crontab: [
       {"* * * * *", ElixirconfChat.Jobs.SaveMessages}
     ]}
  ],
  queues: [events: 10, default: 10]

# Use Tzdata time zone database
config :elixir, :time_zone_database, Tz.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

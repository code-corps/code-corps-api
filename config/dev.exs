use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :code_corps, CodeCorps.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

# Watch static and templates for browser reloading.
config :code_corps, CodeCorps.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :code_corps, CodeCorps.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_POSTGRESQL_USERNAME") || "postgres",
  password: System.get_env("DATABASE_POSTGRESQL_PASSWORD") || "postgres",
  hostname: System.get_env("DATABASE_POSTGRESQL_HOST") || "localhost",
  database: "code_corps_phoenix_dev",
  pool_size: 10

# CORS allowed origins
config :code_corps, allowed_origins: ["http://localhost:4200"]

config :guardian, Guardian,
  secret_key: "e62fb6e2746f6b1bf8b5b735ba816c2eae1d5d76e64f18f3fc647e308b0c159e"

config :code_corps, :analytics, CodeCorps.Analytics.InMemoryAPI
config :code_corps, :stripe, Stripe

config :sentry,
  environment_name: Mix.env || :dev

config :stripe_eventex, api_key: System.get_env("STRIPE_SECRET_KEY")
config :stripe_eventex, subscibed_events: [
  {"account.updated", CodeCorps.Stripe.Events.AccountUpdated},
  {"customer.subscription.updated", CodeCorps.Stripe.Events.CustomerSubscriptionUpdated}
]

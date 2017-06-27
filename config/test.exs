use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :code_corps, CodeCorps.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :code_corps, CodeCorps.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_POSTGRESQL_USERNAME") || "postgres",
  password: System.get_env("DATABASE_POSTGRESQL_PASSWORD") || "postgres",
  hostname: System.get_env("DATABASE_POSTGRESQL_HOST") || "localhost",
  database: "code_corps_phoenix_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :code_corps, site_url: "http://localhost:4200"

# speed up password hashing
config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1

# CORS allowed origins
config :code_corps, allowed_origins: ["http://localhost:4200"]

config :guardian, Guardian,
  secret_key: "e62fb6e2746f6b1bf8b5b735ba816c2eae1d5d76e64f18f3fc647e308b0c159e"

config :code_corps, :analytics, CodeCorps.Analytics.TestAPI

config :code_corps,
  # GitHub webhook API uses cased header names in their requests
  # However, in the test environment, Plug.Conn enforces headers to be
  # lowercased and errors out otherwise.
  github_event_type_header: ("x-github-event"),
  github_event_id_header: ("x-github-delivery")

# Configures stripe for test mode
config :code_corps, :stripe, CodeCorps.StripeTesting
config :code_corps, :stripe_env, :test

config :code_corps, :icon_color_generator, CodeCorps.RandomIconColor.TestGenerator

# Set Corsica logging to output no console warning when rejecting a request
config :code_corps, :corsica_log_level, [rejected: :debug]

config :sentry,
  environment_name: Mix.env || :test

config :code_corps, CodeCorps.Mailer,
  adapter: Bamboo.TestAdapter

config :code_corps,
  postmark_forgot_password_template: "123",
  postmark_project_acceptance_template: "123",
  postmark_receipt_template: "123"

config :code_corps, :cloudex, CloudexTest
config :cloudex, api_key: "test_key", secret: "test_secret", cloud_name: "test_cloud_name"

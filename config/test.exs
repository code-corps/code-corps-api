use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :code_corps, CodeCorpsWeb.Endpoint,
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

config :code_corps, CodeCorps.Guardian,
  secret_key: "e62fb6e2746f6b1bf8b5b735ba816c2eae1d5d76e64f18f3fc647e308b0c159e"

config :code_corps, :analytics, CodeCorps.Analytics.TestAPI

# Configures stripe for test mode
config :code_corps, :stripe, CodeCorps.StripeTesting
config :code_corps, :stripe_env, :test

config :code_corps, :icon_color_generator, CodeCorps.RandomIconColor.TestGenerator

# Set Corsica logging to output no console warning when rejecting a request
config :code_corps, :corsica_log_level, [rejected: :debug]

# fall back to sample pem if none is available as an ENV variable
pem = case System.get_env("GITHUB_TEST_APP_PEM") do
  nil -> "./test/fixtures/github/app.pem" |> File.read!
  encoded_pem -> encoded_pem |> Base.decode64!
end

config :code_corps,
  github: CodeCorps.GitHub.SuccessAPI,
  github_app_id: System.get_env("GITHUB_TEST_APP_ID"),
  github_app_client_id: System.get_env("GITHUB_TEST_APP_CLIENT_ID"),
  github_app_client_secret: System.get_env("GITHUB_TEST_APP_CLIENT_SECRET"),
  github_app_pem: pem

config :sentry,
  environment_name: Mix.env || :test

config :code_corps, :sentry, CodeCorps.Sentry.Sync

config :code_corps, :processor, CodeCorps.Processor.Sync

config :code_corps, CodeCorps.Mailer,
  adapter: Bamboo.TestAdapter

config :code_corps,
  postmark_forgot_password_template: "123",
  postmark_message_initiated_by_project_template: "123",
  postmark_organization_invite_email_template: "123",
  postmark_project_approval_request_template: "123",
  postmark_project_approved_template: "123",
  postmark_project_user_acceptance_template: "123",
  postmark_project_user_request_template: "123",
  postmark_receipt_template: "123",
  postmark_reply_to_conversation_template: "123"

config :code_corps, :cloudex, CloudexTest
config :cloudex, api_key: "test_key", secret: "test_secret", cloud_name: "test_cloud_name"

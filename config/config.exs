# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :code_corps,
  ecto_repos: [CodeCorps.Repo]

# Configures the endpoint
config :code_corps, CodeCorpsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "eMl0+Byu0Zv7q48thBu23ChBVFO1+sdLqoMI8yZoxEviF1K3C5uIohbDfvM9felL",
  render_errors: [view: CodeCorpsWeb.ErrorView, accepts: ~w(html json json-api)],
  pubsub: [name: CodeCorps.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures JSON API encoding
config :phoenix, :format_encoders,
  "json-api": Poison

# Configures JSON API mime type
config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :code_corps,
  sparkpost_forgot_password_template: System.get_env("SPARKPOST_FORGOT_PASSWORD_TEMPLATE") || "forgot-password",
  sparkpost_message_initiated_by_project_template: System.get_env("SPARKPOST_MESSAGE_INITIATED_BY_PROJECT_TEMPLATE") || "message-initiated-by-project",
  sparkpost_organization_invite_template: System.get_env("SPARKPOST_ORGANIZATION_INVITE_TEMPLATE") || "organization-invite",
  sparkpost_project_approval_request_template: System.get_env("SPARKPOST_PROJECT_APPROVAL_REQUEST_TEMPLATE") || "project-approval-request",
  sparkpost_project_approved_template: System.get_env("SPARKPOST_PROJECT_APPROVED_TEMPLATE") || "project-approved",
  sparkpost_project_user_acceptance_template: System.get_env("SPARKPOST_PROJECT_USER_ACCEPTANCE_TEMPLATE") || "project-user-acceptance",
  sparkpost_project_user_request_template: System.get_env("SPARKPOST_PROJECT_USER_REQUEST_TEMPLATE") || "project-user-request",
  sparkpost_receipt_template: System.get_env("SPARKPOST_RECEIPT_TEMPLATE") || "receipt",
  sparkpost_reply_to_conversation_template: System.get_env("SPARKPOST_REPLY_TO_CONVERSATION_TEMPLATE") || "reply-to-conversation"

config :code_corps, CodeCorps.Guardian,
  issuer: "CodeCorps",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

# Configures ex_aws with credentials
config :ex_aws, :code_corps,
  access_key_id: [System.get_env("AWS_ACCESS_KEY_ID"), :instance_role],
  secret_access_key: [System.get_env("AWS_SECRET_ACCESS_KEY"), :instance_role]

config :code_corps,
  asset_host: System.get_env("CLOUDFRONT_DOMAIN")

config :code_corps,
  intercom_identity_secret_key: System.get_env("INTERCOM_IDENTITY_SECRET_KEY")

config :segment,
  write_key: System.get_env("SEGMENT_WRITE_KEY")

config :code_corps, :cloudex, Cloudex
config :cloudex,
  api_key: System.get_env("CLOUDEX_API_KEY"),
  secret: System.get_env("CLOUDEX_SECRET"),
  cloud_name: System.get_env("CLOUDEX_CLOUD_NAME")

# Configures random icon color generator
config :code_corps, :icon_color_generator, CodeCorps.RandomIconColor.Generator

# Set Corsica logging to output a console warning when rejecting a request
config :code_corps, :corsica_log_level, [rejected: :warn]

{:ok, pem} = (System.get_env("GITHUB_APP_PEM") || "") |> Base.decode64()

config :code_corps,
  github: CodeCorps.GitHub.API.Gateway,
  github_app_id: System.get_env("GITHUB_APP_ID"),
  github_app_client_id: System.get_env("GITHUB_APP_CLIENT_ID"),
  github_app_client_secret: System.get_env("GITHUB_APP_CLIENT_SECRET"),
  github_app_pem: pem

config :code_corps,
  sparkpost: CodeCorps.SparkPost.ExtendedAPI

config :stripity_stripe,
  api_key: System.get_env("STRIPE_SECRET_KEY"),
  connect_client_id: System.get_env("STRIPE_PLATFORM_CLIENT_ID")

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  enable_source_code_context: true,
  included_environments: ~w(prod staging)a

config :sparkpost,
  api_key: System.get_env("SPARKPOST_API_KEY")

config :code_corps, :sentry, CodeCorps.Sentry.Async

config :code_corps, :processor, CodeCorps.Processor.Async

config :code_corps, password_reset_timeout: 3600

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Import Timber, structured logging
import_config "timber.exs"

import_config "scout_apm.exs"

config :code_corps, CodeCorps.Repo,
  loggers: [{Ecto.LogEntry, :log, []},
            {ScoutApm.Instruments.EctoLogger, :log, []}]

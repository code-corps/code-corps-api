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
config :code_corps, CodeCorps.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "eMl0+Byu0Zv7q48thBu23ChBVFO1+sdLqoMI8yZoxEviF1K3C5uIohbDfvM9felL",
  render_errors: [view: CodeCorps.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CodeCorps.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures JSON API encoding
config :phoenix, :format_encoders,
  "json-api": Poison

# Configures JSON API mime type
config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}

config :guardian, Guardian,
  issuer: "CodeCorps",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: System.get_env("GUARDIAN_SECRET_KEY"),
  serializer: CodeCorps.GuardianSerializer

config :canary, repo: CodeCorps.Repo
config :canary, unauthorized_handler: {CodeCorps.AuthenticationHelpers, :handle_unauthorized}
config :canary, not_found_handler: {CodeCorps.AuthenticationHelpers, :handle_not_found}

# Configures ex_aws with credentials
config :ex_aws,
  access_key_id: [System.get_env("AWS_ACCESS_KEY_ID"), :instance_role],
  secret_access_key: [System.get_env("AWS_SECRET_ACCESS_KEY"), :instance_role]

# Configures Arc for image uploads
config :arc,
  bucket: System.get_env("S3_BUCKET"),
  asset_host: System.get_env("CLOUDFRONT_DOMAIN")

# Configures Segment for analytics
config :code_corps, :analytics, CodeCorps.Analytics.Segment

config :segment,
  write_key: System.get_env("SEGMENT_WRITE_KEY")

# Configures random icon color generator
config :code_corps, :icon_color_generator, CodeCorps.RandomIconColor.Generator

# Set Corsica logging to output a console warning when rejecting a request
config :code_corps, :corsica_log_level, [rejected: :warn]

config :stripity_stripe, secret_key: System.get_env("STRIPE_SECRET_KEY")
config :stripity_stripe, platform_client_id: System.get_env("STRIPE_PLATFORM_CLIENT_ID")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

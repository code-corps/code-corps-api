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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

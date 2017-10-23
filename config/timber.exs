use Mix.Config

# Update the instrumenters so that we can structure Phoenix logs
config :code_corps, CodeCorpsWeb.Endpoint,
  instrumenters: [Timber.Integrations.PhoenixInstrumenter]

# Structure Ecto logs
config :code_corps, CodeCorps.Repo,
  loggers: [{Timber.Integrations.EctoLogger, :log, []}]

# Sets the Logger application to use the `:console` backend with UTC-oriented
# timestamps
config :logger,
  backends: [:console],
  utc_log: true

# Configures the `:console` backend to:
#   - Use Timber.Formatter.format/4 to format log lines
#   - Pass _all_ metadata for every log line into formatters
config :logger, :console,
  format: {Timber.Formatter, :format},
  metadata: :all

# Configures the Timber.Formatter to:
#   - Colorize the log level
#   - Format metadata using logfmt (if metadata printing is enabled)
#   - Print the log level
#   - Print the timestamp
# Note: print_metadata is false, so the format key will be ignored
config :timber, Timber.Formatter,
  colorize: true,
  format: :logfmt,
  print_log_level: true,
  print_metadata: false,
  print_timestamps: true

# Compiling the configuration from the following Mix environments will result
# in the Timber.Formatter using a "production friendly" configuration.
environments_to_include = [
  :prod,
  :staging
]

if Enum.member?(environments_to_include, Mix.env()) do
  # Configures the Timber.Formatter for outputting to Heroku Logplex
  #   - Removes log level colorization (since the colorization codes are not machine-friendly)
  #   - Formats the data using the JSON formatter
  #   - Removes the log level (this is in the metadata)
  #   - Prints the metadata at the end of the line
  #   - Removes the timestamp (this is in the metadata and Heroku will also add its own)
  config :timber, Timber.Formatter,
    colorize: false,
    format: :json,
    print_log_level: false,
    print_metadata: true,
    print_timestamps: false
end

# Need help?
# Email us: support@timber.io
# Or, file an issue: https://github.com/timberio/timber-elixir/issues

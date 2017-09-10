use Mix.Config

# Update the instrumenters so that we can structure Phoenix logs
config :code_corps, CodeCorpsWeb.Endpoint,
  instrumenters: [Timber.Integrations.PhoenixInstrumenter]

# Structure Ecto logs
config :code_corps, CodeCorps.Repo,
  loggers: [{Timber.Integrations.EctoLogger, :log, []}]

# Use Timber as the logger backend
# Feel free to add additional backends if you want to send you logs to multiple devices.
# For Heroku, use the `:console` backend provided with Logger but customize
# it to use Timber's internal formatting system
config :logger,
  backends: [:console],
  utc_log: true

config :logger, :console,
  format: {Timber.Formatter, :format},
  metadata: [:timber_context, :event, :application, :file, :function, :line, :module, :meta]

# For the following environments, do not log to the Timber service. Instead, log to STDOUT
# and format the logs properly so they are human readable.
environments_to_exclude = [:test]
if Enum.member?(environments_to_exclude, Mix.env()) do
  # Fall back to the default `:console` backend with the Timber custom formatter
  config :logger,
    backends: [:console],
    utc_log: true

  config :logger, :console,
    format: {Timber.Formatter, :format},
    metadata: [:timber_context, :event, :application, :file, :function, :line, :module, :meta]

  config :timber, Timber.Formatter,
    colorize: true,
    format: :logfmt,
    print_timestamps: true,
    print_log_level: true,
    print_metadata: false # turn this on to view the additiional metadata
end

# Need help?
# Email us: support@timber.io
# Or, file an issue: https://github.com/timberio/timber-elixir/issues

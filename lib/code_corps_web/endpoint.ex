defmodule CodeCorpsWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :code_corps

  socket "/socket", CodeCorpsWeb.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :code_corps, gzip: false,
    only: ~w(robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_code_corps_key",
    signing_salt: "RJebPcfU"

  plug Corsica, [
    origins: Application.get_env(:code_corps, :allowed_origins),
    allow_headers: ["accept", "authorization", "content-type", "origin", "x-requested-with"],
    log: Application.get_env(:code_corps, :corsica_log_level)
  ]
  # Add Timber plugs for capturing HTTP context and events
  plug Timber.Integrations.SessionContextPlug
  plug Timber.Integrations.HTTPContextPlug
  plug Timber.Integrations.EventPlug

  plug CodeCorpsWeb.Router
end

defmodule CodeCorps.Auth.EnsureAuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :code_corps,
                              module: CodeCorps.Guardian,
                              error_handler: CodeCorps.Auth.ErrorHandler

  plug Guardian.Plug.EnsureAuthenticated
end

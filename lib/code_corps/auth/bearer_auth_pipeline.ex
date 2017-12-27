defmodule CodeCorps.Auth.BearerAuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :code_corps,
                              module: CodeCorps.Guardian,
                              error_handler: CodeCorps.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end

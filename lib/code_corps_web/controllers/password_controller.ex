defmodule CodeCorpsWeb.PasswordController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Services.ForgotPasswordService}

  @doc """
  Generates a `CodeCorps.AuthToken` model to verify against and sends an email.
  """
  def forgot_password(conn, %{"email" => email}) do
    ForgotPasswordService.forgot_password(email)

    conn
    |> CodeCorps.Guardian.Plug.sign_out()
    |> put_status(:ok)
    |> render("show.json", email: email)
  end
end

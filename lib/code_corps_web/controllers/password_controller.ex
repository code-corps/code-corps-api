defmodule CodeCorpsWeb.PasswordController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Services.ForgotPasswordService}

  @doc"""
  forgot_password should take an email and generate an AuthToken model and send an email
  """
  def forgot_password(conn, %{"email" => email}) do
    ForgotPasswordService.forgot_password(email)
    conn |> put_status(:ok) |> render("show.json", email: email)
  end

end

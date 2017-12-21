defmodule CodeCorps.SparkPost.Emails do
  alias CodeCorps.SparkPost.{API, Emails}

  def send_forgot_password_email(user, token) do
    user |> Emails.ForgotPassword.build(token) |> API.send_transmission
  end
end

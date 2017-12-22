defmodule CodeCorps.SparkPost.Emails do
  alias CodeCorps.SparkPost.{API, Emails}

  def send_forgot_password_email(user, token) do
    user |> Emails.ForgotPassword.build(token) |> API.send_transmission
  end

  def send_receipt_email(charge, invoice) do
    case charge |> Emails.Receipt.build(invoice) do
      %SparkPost.Transmission{} = transmission ->
        transmission |> API.send_transmission
      build_failure -> build_failure
    end
  end
end

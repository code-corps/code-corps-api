defmodule CodeCorps.Emails.ForgotPasswordEmail do
  import Bamboo.Email
  import Bamboo.PostmarkHelper

  alias CodeCorps.{Emails.BaseEmail, WebClient}

  def create(user, token) do
    BaseEmail.create
    |> to(user.email)
    |> template(template_id(), %{link: link(token)})
  end

  defp template_id, do: Application.get_env(:code_corps, :postmark_forgot_password_template)

  defp link(token) do
    WebClient.url()
    |> URI.merge("password/reset?token=#{token}")
    |> URI.to_string
  end
end

defmodule CodeCorps.Emails.ForgotPasswordEmail do
  import Bamboo.Email, only: [to: 2]
  import Bamboo.PostmarkHelper

  alias CodeCorps.{Emails.BaseEmail, User, WebClient}

  @spec create(User.t, String.t) :: Bamboo.Email.t
  def create(%User{} = user, token) do
    BaseEmail.create
    |> to(user.email)
    |> template(template_id(), %{link: link(token)})
  end

  @spec template_id :: String.t
  defp template_id, do: Application.get_env(:code_corps, :postmark_forgot_password_template)

  @spec link(String.t) :: String.t
  defp link(token) do
    WebClient.url()
    |> URI.merge("password/reset?token=#{token}")
    |> URI.to_string
  end
end

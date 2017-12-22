defmodule CodeCorps.Emails.Transmissions.ForgotPassword do

  alias SparkPost.{Content, Transmission}
  alias CodeCorps.{Emails.Recipient, User, WebClient}

  @spec build(User.t, String.t) :: %Transmission{}
  def build(%User{} = user, token) do
    %Transmission{
      content: %Content.TemplateRef{template_id: template_id()},
      options: %Transmission.Options{inline_css: true},
      recipients: [user |> Recipient.build],
      substitution_data: %{
        from_name: "Code Corps",
        from_email: "team@codecorps.org",
        link: link(token),
        subject: "Here's the link to reset your password"
      }
    }
  end

  @spec link(String.t) :: String.t
  defp link(token) do
    WebClient.url()
    |> URI.merge("password/reset?token=#{token}")
    |> URI.to_string
  end

  @doc ~S"""
  Returns configured template ID for this email
  """
  @spec template_id :: String.t
  def template_id do
    Application.get_env(:code_corps, :sparkpost_forgot_password_template)
  end
end

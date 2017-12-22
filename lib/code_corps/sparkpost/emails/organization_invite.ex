defmodule CodeCorps.SparkPost.Emails.OrganizationInvite do
  alias SparkPost.{Content, Transmission}
  alias CodeCorps.{OrganizationInvite, SparkPost.Emails.Recipient, WebClient}

  @spec build(OrganizationInvite.t) :: %Transmission{}
  def build(%OrganizationInvite{} = invite) do
    %Transmission{
      content: %Content.TemplateRef{template_id: template_id()},
      options: %Transmission.Options{inline_css: true},
      recipients: [invite |> Recipient.build],
      substitution_data: %{
        from_name: "Code Corps",
        from_email: "team@codecorps.org",
        organization_name: invite.organization_name,
        invite_url: invite_url(invite.code, invite.organization_name),
        subject: "Create your first project on Code Corps"
      }
    }
  end

  @spec invite_url(String.t, String.t) :: String.t
  defp invite_url(code, organization_name) do
    query_params = set_params(code, organization_name)
    WebClient.url()
    |> URI.merge("/organizations/new" <> "?" <> query_params)
    |> URI.to_string
  end

  @spec set_params(String.t, String.t) :: binary
  defp set_params(code, organization_name) do
    %{code: code, organization_name: organization_name}
    |> URI.encode_query
  end

  @doc ~S"""
  Returns configured template ID for this email
  """
  @spec template_id :: String.t
  def template_id do
    Application.get_env(:code_corps, :sparkpost_organization_invite_template)
  end
end

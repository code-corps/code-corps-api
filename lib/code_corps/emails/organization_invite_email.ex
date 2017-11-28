defmodule CodeCorps.Emails.OrganizationInviteEmail do
  import Bamboo.Email, only: [to: 2]
  import Bamboo.PostmarkHelper

  alias CodeCorps.{Emails.BaseEmail, OrganizationInvite, WebClient}

  @spec create(OrganizationInvite.t) :: Bamboo.Email.t
  def create(%OrganizationInvite{} = invite) do
    BaseEmail.create
    |> to(invite.email)
    |> template(template_id(), build_model(invite))
  end

  @spec build_model(OrganizationInvite.t) :: map
  defp build_model(%OrganizationInvite{} = invite) do
    %{
      organization_name: invite.organization_name,
      invite_url: invite_url(invite.code, invite.organization_name),
      subject: "Create your first project on Code Corps"
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

  @spec template_id :: String.t
  defp template_id, do: Application.get_env(:code_corps, :organization_invite_email_template)
end

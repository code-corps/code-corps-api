defmodule CodeCorps.Emails.OrganizationInviteEmail do
    import Bamboo.Email
    import Bamboo.PostmarkHelper

    alias CodeCorps.{Emails.BaseEmail, OrganizationInvite, WebClient}

    def create(%OrganizationInvite{} = invite) do
      BaseEmail.create
      |> to(invite.email)
      |> template(template_id(), build_model(invite))
    end

    defp build_model(%OrganizationInvite{} = invite) do
      %{
        organization_name: invite.organization_name,
        invite_url: invite_url(invite.code, invite.organization_name),
        subject: "Create your first project on Code Corps"
      }
    end

    defp invite_url(code, organization_name) do
      WebClient.url()
      |> URI.merge("/invites/organization" <> "?" <> set_params(code, organization_name))
      |> URI.to_string
    end

    defp set_params(code, organization_name) do
      %{code: code, organization_name: organization_name }
      |> URI.encode_query
    end

    defp template_id, do: Application.get_env(:code_corps, :organization_invite_email_template)
end

defmodule CodeCorps.Emails.OrganizationInviteEmail do
    import Bamboo.Email
    import Bamboo.PostmarkHelper
  
    alias CodeCorps.{OrganizationInvite}
    alias CodeCorps.Emails.BaseEmail
  
    def create(%OrganizationInvite{} = organization_invite) do
      BaseEmail.create
      |> to(organization_invite.email)
      |> template(template_id(), build_model(organization_invite))
    end
  
    defp build_model(%OrganizationInvite{} = organization_invite) do
      %{
        title: organization_invite.title,
        url: url(organization_invite.title, organization_invite.code),
        subject: "Create your first project on Code Corps"
      }
    end
  
    defp url(title, code) do
      Application.get_env(:code_corps, :site_url)
      |> URI.merge("/invites/organization" <> "?" <> set_params(code, title))
      |> URI.to_string
    end

    defp set_params(code, title) do
      %{code: code, organization_title: title } 
      |> URI.encode_query
    end
  
    defp template_id, do: Application.get_env(:code_corps, :organization_invite_email_template)
end
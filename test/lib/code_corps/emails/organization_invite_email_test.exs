defmodule CodeCorps.Emails.OrganizationInviteEmailTest do
    use CodeCorps.ModelCase
    use Bamboo.Test
    
    alias CodeCorps.Emails.OrganizationInviteEmail
  
    test "organization email invite works" do
      organization_invite = insert(:organization_invite)    
      email = OrganizationInviteEmail.create(organization_invite)

      assert email.from == "Code Corps<team@codecorps.org>"
      assert email.to == organization_invite.email
      
      template_model = email.private.template_model
      params = 
        %{code: organization_invite.code, organization_title: organization_invite.title}
        |> URI.encode_query

      assert template_model == %{
        title: organization_invite.title,
        url: "#{Application.get_env(:code_corps, :site_url)}/invites/organization?#{params}",
        subject: "Create your first project on Code Corps"
      }
    end
  end
  
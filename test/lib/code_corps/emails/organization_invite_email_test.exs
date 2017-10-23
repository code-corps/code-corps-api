defmodule CodeCorps.Emails.OrganizationInviteEmailTest do
    use CodeCorps.ModelCase
    use Bamboo.Test

    alias CodeCorps.{Emails.OrganizationInviteEmail, WebClient}

    test "organization email invite works" do
      invite = insert(:organization_invite)
      email = OrganizationInviteEmail.create(invite)

      assert email.from == "Code Corps<team@codecorps.org>"
      assert email.to == invite.email

      template_model = email.private.template_model
      params =
        %{code: invite.code, organization_name: invite.organization_name}
        |> URI.encode_query
      invite_url = "#{WebClient.url()}/invites/organization?#{params}"

      assert template_model == %{
        invite_url: invite_url,
        organization_name: invite.organization_name,
        subject: "Create your first project on Code Corps"
      }
    end
  end

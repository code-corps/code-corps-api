defmodule CodeCorps.Emails.Transmissions.OrganizationInviteTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.{Emails.Transmissions.OrganizationInvite, WebClient}

  test "has a template_id assigned" do
    assert OrganizationInvite.template_id
  end

  describe "build/1" do
    test "provides substitution data for all keys used by template" do
      invite = insert(:organization_invite)

      %{substitution_data: data} = OrganizationInvite.build(invite)

      expected_keys =
        OrganizationInvite.template_id
        |> CodeCorps.SparkPostHelpers.get_keys_used_by_template
      assert data |> Map.keys == expected_keys
    end

    test "builds correct transmission model" do
      invite = insert(:organization_invite)

      %{substitution_data: data, recipients: [recipient]} =
        OrganizationInvite.build(invite)

      assert data.from_name == "Code Corps"
      assert data.from_email == "team@codecorps.org"

      assert data.organization_name == invite.organization_name
      assert data.subject == "Create your first project on Code Corps"

      params =
        %{code: invite.code, organization_name: invite.organization_name}
        |> URI.encode_query

      assert data.invite_url == "#{WebClient.url()}/organizations/new?#{params}"

      assert recipient.address.email == invite.email
      assert recipient.address.name == invite.organization_name
    end
  end
end

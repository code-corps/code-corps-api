defmodule CodeCorpsWeb.OrganizationInviteViewTest do
  @moduledoc false

  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    organization_invite = insert(:organization_invite)

    rendered_json = render(CodeCorpsWeb.OrganizationInviteView, "show.json-api", data: organization_invite)

    expected_json = %{
      "data" => %{
        "id" => organization_invite.id |> Integer.to_string,
        "type" => "organization-invite",
        "attributes" => %{
          "email" => organization_invite.email,
          "fulfilled" => organization_invite.fulfilled,
          "inserted-at" => organization_invite.inserted_at,
          "organization-name" => organization_invite.organization_name,
          "updated-at" => organization_invite.updated_at
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

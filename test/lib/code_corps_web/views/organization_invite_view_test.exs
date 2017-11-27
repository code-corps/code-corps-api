defmodule CodeCorpsWeb.OrganizationInviteViewTest do
  @moduledoc false

  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    organization = insert(:organization)
    organization_invite = insert(:organization_invite, organization: organization)

    rendered_json = render(CodeCorpsWeb.OrganizationInviteView, "show.json-api", data: organization_invite)

    expected_json = %{
      "data" => %{
        "id" => organization_invite.id |> Integer.to_string,
        "type" => "organization-invite",
        "attributes" => %{
          "email" => organization_invite.email,
          "inserted-at" => organization_invite.inserted_at,
          "organization-name" => organization_invite.organization_name,
          "updated-at" => organization_invite.updated_at
        },
        "relationships" => %{
          "organization" => %{
            "data" => %{
              "id" => organization.id |> Integer.to_string,
              "type" => "organization"
            }
          }
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

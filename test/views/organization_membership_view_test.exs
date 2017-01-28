defmodule CodeCorps.OrganizationMembershipViewTest do
  use CodeCorps.ViewCase

  test "renders all attributes and relationships properly" do
    organization = insert(:organization)
    user = insert(:user)
    organization_membership = insert(:organization_membership, member: user, organization: organization)

    rendered_json = render(CodeCorps.OrganizationMembershipView, "show.json-api", data: organization_membership)

    expected_json = %{
      "data" => %{
        "id" => organization_membership.id |> Integer.to_string,
        "type" => "organization-membership",
        "attributes" => %{
          "inserted-at" => organization_membership.inserted_at,
          "role" => organization_membership.role,
          "updated-at" => organization_membership.updated_at
        },
        "relationships" => %{
          "member" => %{
            "data" => %{"id" => organization_membership.member_id |> Integer.to_string, "type" => "user"}
          },
          "organization" => %{
            "data" => %{"id" => organization_membership.organization_id |> Integer.to_string, "type" => "organization"}
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

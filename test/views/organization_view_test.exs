defmodule CodeCorps.OrganizationViewTest do
  use CodeCorps.ViewCase

  test "renders all attributes and relationships properly" do
    organization = insert(:organization, default_color: "blue")
    project = insert(:project, organization: organization)
    user = insert(:user)
    organization_membership = insert(:organization_membership, member: user, organization: organization)
    slugged_route = insert(:slugged_route, organization: organization)
    stripe_connect_account = insert(:stripe_connect_account, organization: organization)

    host = Application.get_env(:code_corps, :asset_host)

    rendered_json =  render(CodeCorps.OrganizationView, "show.json-api", data: organization)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "cloudinary-public-id" => nil,
          "description" => organization.description,
          "icon-large-url" => "#{host}/icons/organization_default_large_blue.png",
          "icon-thumb-url" => "#{host}/icons/organization_default_thumb_blue.png",
          "inserted-at" => organization.inserted_at,
          "name" => organization.name,
          "slug" => organization.slug,
          "updated-at" => organization.updated_at,
        },
        "id" => organization.id |> Integer.to_string,
        "relationships" => %{
          "organization-memberships" => %{
            "data" => [
              %{"id" => organization_membership.id |> Integer.to_string, "type" => "organization-membership"}
            ]
          },
          "projects" => %{
            "data" => [
              %{"id" => project.id |> Integer.to_string, "type" => "project"}
            ]
          },
          "slugged-route" => %{
            "data" => %{"id" => slugged_route.id |> Integer.to_string, "type" => "slugged-route"}
          },
          "stripe-connect-account" => %{
            "data" => %{"id" => stripe_connect_account.id |> Integer.to_string, "type" => "stripe-connect-account"}
          },
        },
        "type" => "organization",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

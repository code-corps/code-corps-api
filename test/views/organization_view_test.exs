defmodule CodeCorps.OrganizationViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    organization = insert(:organization)
    project = insert(:project, organization: organization)
    user = insert(:user)
    organization_membership = insert(:organization_membership, member: user, organization: organization)

    organization =
      CodeCorps.Organization
      |> Repo.get(organization.id)
      |> CodeCorps.Repo.preload([:members, :projects, :slugged_route])

    rendered_json =  render(CodeCorps.OrganizationView, "show.json-api", data: organization)

    expected_json = %{
      data: %{
        attributes: %{
          "description" => organization.description,
          "icon-large-url" => CodeCorps.OrganizationIcon.url({organization.icon, organization}, :large),
          "icon-thumb-url" => CodeCorps.OrganizationIcon.url({organization.icon, organization}, :thumb),
          "inserted-at" => organization.inserted_at,
          "name" => organization.name,
          "slug" => organization.slug,
          "updated-at" => organization.updated_at,
        },
        id: organization.id |> Integer.to_string,
        relationships: %{
          "members" => %{
            data: [
              %{id: user.id |> Integer.to_string, type: "user"}
            ]
          },
          "organization-memberships" => %{
            data: [
              %{id: organization_membership.id |> Integer.to_string, type: "organization-membership"}
            ]
          },
          "projects" => %{
            data: [
              %{id: project.id |> Integer.to_string, type: "project"}
            ]
          },
          "slugged-route" => %{
            data: nil
          },
        },
        type: "organization",
      },
      jsonapi: %{
        version: "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

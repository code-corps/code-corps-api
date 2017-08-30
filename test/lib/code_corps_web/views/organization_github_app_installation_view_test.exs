defmodule CodeCorpsWeb.OrganizationGithubAppInstallationViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    github_app_installation = insert(:github_app_installation)
    organization = insert(:organization)
    organization_github_app_installation = insert(:organization_github_app_installation, github_app_installation: github_app_installation, organization: organization)

    rendered_json = render(CodeCorpsWeb.OrganizationGithubAppInstallationView, "show.json-api", data: organization_github_app_installation)

    expected_json = %{
      "data" => %{
        "id" => organization_github_app_installation.id |> Integer.to_string,
        "type" => "organization-github-app-installation",
        "attributes" => %{
          "inserted-at" => organization_github_app_installation.inserted_at,
          "updated-at" => organization_github_app_installation.updated_at
        },
        "relationships" => %{
          "github-app-installation" => %{
            "data" => %{"id" => organization_github_app_installation.github_app_installation_id |> Integer.to_string, "type" => "github-app-installation"}
          },
          "organization" => %{
            "data" => %{"id" => organization_github_app_installation.organization_id |> Integer.to_string, "type" => "organization"}
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

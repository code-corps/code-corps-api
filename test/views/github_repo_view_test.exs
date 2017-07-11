defmodule CodeCorps.GithubRepoViewTest do
  use CodeCorps.ViewCase

  test "renders all attributes and relationships properly" do
    github_app_installation = insert(:github_app_installation)
    github_repo = insert(:github_repo, github_app_installation: github_app_installation)

    rendered_json = render(CodeCorps.GithubRepoView, "show.json-api", data: github_repo)

    expected_json = %{
      "data" => %{
        "id" => github_repo.id |> Integer.to_string,
        "type" => "github-repo",
        "attributes" => %{
          "github-id" => github_repo.github_id,
          "github-account-avatar-url" => github_repo.github_account_avatar_url,
          "github-account-id" => github_repo.github_account_id,
          "github-account-login" => github_repo.github_account_login,
          "github-account-type" => github_repo.github_account_type,
          "inserted-at" => github_repo.inserted_at,
          "name" => github_repo.name,
          "updated-at" => github_repo.updated_at
        },
        "relationships" => %{
          "github-app-installation" => %{
            "data" => %{"id" => github_app_installation.id |> Integer.to_string, "type" => "github-app-installation"}
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

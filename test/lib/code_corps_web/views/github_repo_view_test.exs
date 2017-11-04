defmodule CodeCorpsWeb.GithubRepoViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    github_app_installation = insert(:github_app_installation)
    github_repo = insert(:github_repo, github_app_installation: github_app_installation)

    rendered_json = render(CodeCorpsWeb.GithubRepoView, "show.json-api", data: github_repo)

    expected_json = %{
      "data" => %{
        "id" => github_repo.id |> Integer.to_string,
        "type" => "github-repo",
        "attributes" => %{
          "github-account-avatar-url" => github_repo.github_account_avatar_url,
          "github-account-id" => github_repo.github_account_id,
          "github-account-login" => github_repo.github_account_login,
          "github-account-type" => github_repo.github_account_type,
          "github-id" => github_repo.github_id,
          "inserted-at" => github_repo.inserted_at,
          "name" => github_repo.name,
          "syncing-comments-count" => github_repo.syncing_comments_count,
          "syncing-issues-count" => github_repo.syncing_issues_count,
          "syncing-pull-requests-count" => github_repo.syncing_pull_requests_count,
          "sync-state" => github_repo.sync_state,
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

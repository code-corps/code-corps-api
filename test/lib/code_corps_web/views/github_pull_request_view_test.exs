defmodule CodeCorpsWeb.GithubPullRequestViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    github_repo = insert(:github_repo)
    github_pull_request = insert(:github_pull_request, github_repo: github_repo)

    rendered_json = render(CodeCorpsWeb.GithubPullRequestView, "show.json-api", data: github_pull_request)

    expected_json = %{
      "data" => %{
        "id" => github_pull_request.id |> Integer.to_string,
        "type" => "github-pull-request",
        "attributes" => %{
          "github-created-at" => github_pull_request.github_created_at,
          "github-updated-at" => github_pull_request.github_updated_at,
          "html-url" => github_pull_request.html_url,
          "merged" => github_pull_request.merged,
          "number" => github_pull_request.number,
          "state" => github_pull_request.state
        },
        "relationships" => %{
          "github-repo" => %{
            "data" => %{"id" => github_repo.id |> Integer.to_string, "type" => "github-repo"}
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

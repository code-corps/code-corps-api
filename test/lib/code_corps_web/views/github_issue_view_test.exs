defmodule CodeCorpsWeb.GithubIssueViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    github_repo = insert(:github_repo)
    github_pull_request = insert(:github_pull_request)
    github_issue = insert(:github_issue, github_pull_request: github_pull_request, github_repo: github_repo)

    rendered_json = render(CodeCorpsWeb.GithubIssueView, "show.json-api", data: github_issue)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "body" => github_issue.body,
          "closed-at" => github_issue.closed_at,
          "comments-url" => github_issue.comments_url,
          "events-url" => github_issue.events_url,
          "github-created-at" => github_issue.github_created_at,
          "github-id" => github_issue.github_id,
          "github-updated-at" => github_issue.github_updated_at,
          "html-url" => github_issue.html_url,
          "labels-url" => github_issue.labels_url,
          "locked" => github_issue.locked,
          "number" => github_issue.number,
          "state" => github_issue.state,
          "title" => github_issue.title,
          "url" => github_issue.url
        },
        "id" => github_issue.id |> Integer.to_string,
        "relationships" => %{
          "github-pull-request" => %{
            "data" => %{
              "id" => github_issue.github_pull_request_id |> Integer.to_string,
              "type" => "github-pull-request"
            }
          },
          "github-repo" => %{
            "data" => %{
              "id" => github_issue.github_repo_id |> Integer.to_string,
              "type" => "github-repo"
            }
          }
        },
        "type" => "github-issue",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

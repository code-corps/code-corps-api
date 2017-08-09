defmodule CodeCorpsWeb.ProjectGithubRepoViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    project_github_repo = insert(:project_github_repo)

    rendered_json = render(CodeCorpsWeb.ProjectGithubRepoView, "show.json-api", data: project_github_repo)

    expected_json = %{
      "data" => %{
        "id" => project_github_repo.id |> Integer.to_string,
        "type" => "project-github-repo",
        "attributes" => %{},
        "relationships" => %{
          "github-repo" => %{
            "data" => %{"id" => project_github_repo.github_repo_id |> Integer.to_string, "type" => "github-repo"}
          },
          "project" => %{
            "data" => %{"id" => project_github_repo.project_id |> Integer.to_string, "type" => "project"}
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

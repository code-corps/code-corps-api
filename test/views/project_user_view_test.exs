defmodule CodeCorps.ProjectUserViewTest do
  use CodeCorps.ViewCase

  test "renders all attributes and relationships properly" do
    project = insert(:project)
    user = insert(:user)
    project_user = insert(:project_user, project: project, user: user)

    rendered_json = render(CodeCorps.ProjectUserView, "show.json-api", data: project_user)

    expected_json = %{
      "data" => %{
        "id" => project_user.id |> Integer.to_string,
        "type" => "project-user",
        "attributes" => %{
          "inserted-at" => project_user.inserted_at,
          "role" => project_user.role,
          "updated-at" => project_user.updated_at
        },
        "relationships" => %{
          "project" => %{
            "data" => %{"id" => project_user.project_id |> Integer.to_string, "type" => "project"}
          },
          "user" => %{
            "data" => %{"id" => project_user.user_id |> Integer.to_string, "type" => "user"}
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

defmodule CodeCorps.Web.ProjectSkillViewTest do
  use CodeCorps.Web.ViewCase

  test "renders all attributes and relationships properly" do
    project_skill = insert(:project_skill)

    rendered_json = render(CodeCorps.Web.ProjectSkillView, "show.json-api", data: project_skill)

    expected_json = %{
      "data" => %{
        "id" => project_skill.id |> Integer.to_string,
        "type" => "project-skill",
        "attributes" => %{},
        "relationships" => %{
          "project" => %{
            "data" => %{"id" => project_skill.project_id |> Integer.to_string, "type" => "project"}
          },
          "skill" => %{
            "data" => %{"id" => project_skill.skill_id |> Integer.to_string, "type" => "skill"}
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

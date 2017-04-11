defmodule CodeCorps.Web.RoleSkillViewTest do
  use CodeCorps.Web.ViewCase

  test "renders all attributes and relationships properly" do
    role_skill = insert(:role_skill)

    rendered_json = render(CodeCorps.Web.RoleSkillView, "show.json-api", data: role_skill)

    expected_json = %{
      "data" => %{
        "id" => role_skill.id |> Integer.to_string,
        "type" => "role-skill",
        "attributes" => %{},
        "relationships" => %{
          "skill" => %{
            "data" => %{"id" => role_skill.skill_id |> Integer.to_string, "type" => "skill"}
          },
          "role" => %{
            "data" => %{"id" => role_skill.role_id |> Integer.to_string, "type" => "role"}
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

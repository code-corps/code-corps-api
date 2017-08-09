defmodule CodeCorpsWeb.UserSkillViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    user_skill = insert(:user_skill)

    rendered_json = render(CodeCorpsWeb.UserSkillView, "show.json-api", data: user_skill)

    expected_json = %{
      "data" => %{
        "id" => user_skill.id |> Integer.to_string,
        "type" => "user-skill",
        "attributes" => %{},
        "relationships" => %{
          "skill" => %{
            "data" => %{"id" => user_skill.skill_id |> Integer.to_string, "type" => "skill"}
          },
          "user" => %{
            "data" => %{"id" => user_skill.user_id |> Integer.to_string, "type" => "user"}
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

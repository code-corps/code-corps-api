defmodule CodeCorps.SkillViewTest do
  use CodeCorps.ConnCase, async: true

  import Phoenix.View, only: [render: 3]

  test "renders all attributes and relationships properly" do
    skill = insert(:skill)
    role_skill = insert(:role_skill, skill: skill)

    rendered_json =  render(CodeCorps.SkillView, "show.json-api", data: skill)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "description" => skill.description,
          "inserted-at" => skill.inserted_at,
          "title" => skill.title,
          "updated-at" => skill.updated_at,
        },
        "id" => skill.id |> Integer.to_string,
        "relationships" => %{
          "role-skills" => %{
            "data" => [
              %{"id" => role_skill.id |> Integer.to_string, "type" => "role-skill"}
            ]
          }
        },
        "type" => "skill",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

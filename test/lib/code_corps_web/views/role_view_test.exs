defmodule CodeCorpsWeb.RoleViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    role = insert(:role)
    role_skill = insert(:role_skill, role: role)

    role = CodeCorpsWeb.RoleController.preload(role)
    rendered_json =  render(CodeCorpsWeb.RoleView, "show.json-api", data: role)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "ability" => role.ability,
          "inserted-at" => role.inserted_at,
          "kind" => role.kind,
          "name" => role.name,
          "updated-at" => role.updated_at,
        },
        "id" => role.id |> Integer.to_string,
        "relationships" => %{
          "role-skills" => %{
            "data" => [
              %{"id" => role_skill.id |> Integer.to_string, "type" => "role-skill"}
            ]
          }
        },
        "type" => "role",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

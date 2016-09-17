defmodule CodeCorps.RoleViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    role = insert(:role)
    skill = insert(:skill)
    role_skill = insert(:role_skill, role: role, skill: skill)

    role =
      CodeCorps.Role
      |> Repo.get(role.id)
      |> Repo.preload([:skills])

    rendered_json =  render(CodeCorps.RoleView, "show.json-api", data: role)

    expected_json = %{
      data: %{
        attributes: %{
          "ability" => role.ability,
          "inserted-at" => role.inserted_at,
          "kind" => role.kind,
          "name" => role.name,
          "updated-at" => role.updated_at,
        },
        id: role.id |> Integer.to_string,
        relationships: %{
          "role-skills" => %{
            data: [
              %{id: role_skill.id |> Integer.to_string, type: "role-skill"}
            ]
          },
          "skills" => %{
            data: [
              %{id: skill.id |> Integer.to_string, type: "skill"}
            ]
          }
        },
        type: "role",
      },
      jsonapi: %{
        version: "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

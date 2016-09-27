defmodule CodeCorps.RoleViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    role_skill = insert(:role_skill)

    role =
      CodeCorps.Role
      |> Repo.get(role_skill.role_id)
      |> Repo.preload([:role_skills])

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

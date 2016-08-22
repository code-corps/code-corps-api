defmodule CodeCorps.UserRoleViewTest do
  use CodeCorps.ConnCase, async: true

  import CodeCorps.Factories

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    db_user_role = insert(:user_role)

    user_role =
      CodeCorps.UserRole
      |> Repo.get(db_user_role.id)
      |> Repo.preload([:user, :role])

    rendered_json = render(CodeCorps.UserRoleView, "show.json-api", data: user_role)

    expected_json = %{
      data: %{
        id: user_role.id |> Integer.to_string,
        type: "user-role",
        attributes: %{},
        relationships: %{
          "role" => %{
            data: %{id: user_role.role_id |> Integer.to_string, type: "role"}
          },
          "user" => %{
            data: %{id: user_role.user_id |> Integer.to_string, type: "user"}
          }
        }
      },
      jsonapi: %{
        version: "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

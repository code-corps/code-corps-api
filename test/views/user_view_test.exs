defmodule CodeCorps.UserViewTest do
  use CodeCorps.ConnCase, async: true

  import CodeCorps.Factories

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    db_user = insert(:user)
    user_category = insert(:user_category, user: db_user)
    user_role = insert(:user_role, user: db_user)
    user_skill = insert(:user_skill, user: db_user)

    user =
      CodeCorps.User
      |> Repo.get(db_user.id)
      |> CodeCorps.Repo.preload([:categories, :roles, :skills, :slugged_route])

    rendered_json =  render(CodeCorps.UserView, "show.json-api", data: user)

    expected_json = %{
      data: %{
        id: user.id |> Integer.to_string,
        type: "user",
        attributes: %{
          "username" => user.username,
          "email" => user.email,
          "photo-large-url" => CodeCorps.UserPhoto.url({user.photo, user}, :large),
          "photo-thumb-url" => CodeCorps.UserPhoto.url({user.photo, user}, :thumb),
          "inserted-at" => user.inserted_at,
          "updated-at" => user.updated_at
        },
        relationships: %{
          "categories" => %{
            data: [
              %{id: user_category.category_id |> Integer.to_string, type: "category"}
            ]
          },
          "roles" => %{
            data: [
              %{id: user_role.role_id |> Integer.to_string, type: "role"}
            ]
          },
          "skills" => %{
            data: [
              %{id: user_skill.skill_id |> Integer.to_string, type: "skill"}
            ]
          },
          "slugged-route" => %{
            data: nil
          },
          "user-categories" => %{
            data: [
              %{id: user_category.id |> Integer.to_string, type: "user-category"}
            ]
          },
          "user-roles" => %{
            data: [
              %{id: user_role.id |> Integer.to_string, type: "user-role"}
            ]
          },
          "user-skills" => %{
            data: [
              %{id: user_skill.id |> Integer.to_string, type: "user-skill"}
            ]
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

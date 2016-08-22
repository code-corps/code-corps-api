defmodule CodeCorps.UserViewTest do
  use CodeCorps.ConnCase, async: true

  import CodeCorps.Factories

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    user_role = insert(:user_role)

    user =
      CodeCorps.User
      |> Repo.get(user_role.user_id)
      |> CodeCorps.Repo.preload([:slugged_route, :roles])

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
          "roles" => %{
            data: [
              %{id: user_role.role_id |> Integer.to_string, type: "role"}
            ]
          },
          "slugged-route" => %{
            data: nil
          },
          "user-roles" => %{
            data: [
              %{id: user_role.id |> Integer.to_string, type: "user-role"}
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

defmodule CodeCorps.UserViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    db_user = insert(:user)
    organization_membership = insert(:organization_membership, member: db_user)
    user_category = insert(:user_category, user: db_user)
    user_role = insert(:user_role, user: db_user)
    user_skill = insert(:user_skill, user: db_user)

    user =
      CodeCorps.User
      |> Repo.get(db_user.id)
      |> CodeCorps.Repo.preload([:categories, :organizations, :roles, :skills, :slugged_route])

    rendered_json = render(CodeCorps.UserView, "show.json-api", data: user)

    expected_json = %{
      data: %{
        id: user.id |> Integer.to_string,
        type: "user",
        attributes: %{
          "biography" => user.biography,
          "email" => "",
          "first-name" => user.first_name,
          "last-name" => user.last_name,
          "inserted-at" => user.inserted_at,
          "photo-large-url" => CodeCorps.UserPhoto.url({user.photo, user}, :large),
          "photo-thumb-url" => CodeCorps.UserPhoto.url({user.photo, user}, :thumb),
          "twitter" => user.twitter,
          "username" => user.username,
          "updated-at" => user.updated_at,
          "website" => user.website,
          "state" => "signed_up"
        },
        relationships: %{
          "categories" => %{
            data: [
              %{id: user_category.category_id |> Integer.to_string, type: "category"}
            ]
          },
          "organizations" => %{
            data: [
              %{id: organization_membership.organization_id |> Integer.to_string, type: "organization"}
            ]
          },
          "organization-memberships" => %{
            data: [
              %{id: organization_membership.id |> Integer.to_string, type: "organization-membership"}
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

  test "renders email when user is the authenticated user" do
    db_user = insert(:user)
    user =
      CodeCorps.User
      |> Repo.get(db_user.id)
      |> CodeCorps.Repo.preload([:categories, :organizations, :roles, :skills, :slugged_route])

    conn = Phoenix.ConnTest.build_conn |> assign(:current_user, user)
    rendered_json = render(CodeCorps.UserView, "show.json-api", data: user, conn: conn)
    assert rendered_json[:data][:attributes]["email"] == user.email
  end

  test "renders email for only the authenticated user when rendering list" do
      auth_user = insert(:user)
      insert_list(3, :user)

      users =
        CodeCorps.User
        |> Repo.all
        |> CodeCorps.Repo.preload([:categories, :organizations, :roles, :skills, :slugged_route])

      conn = Phoenix.ConnTest.build_conn |> assign(:current_user, auth_user)
      rendered_json = render(CodeCorps.UserView, "show.json-api", data: users, conn: conn)

      emails =
        rendered_json[:data]
        |> Enum.map(&Map.get(&1, :attributes))
        |> Enum.map(&Map.get(&1, "email"))
        |> Enum.filter(fn(email) -> email != "" end)

      assert emails == [auth_user.email]
    end
end

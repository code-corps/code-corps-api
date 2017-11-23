defmodule CodeCorpsWeb.UserViewTest do
  use CodeCorpsWeb.ViewCase

  alias CodeCorpsWeb.UserView
  alias Phoenix.ConnTest
  alias Plug.Conn

  test "renders all attributes and relationships properly" do
    user = insert(:user, first_name: "First", github_avatar_url: "foo", github_id: 123, github_username: "githubuser", last_name: "Last", default_color: "blue")
    github_app_installation = insert(:github_app_installation, user: user)
    slugged_route = insert(:slugged_route, user: user)
    stripe_connect_subscription = insert(:stripe_connect_subscription, user: user)
    stripe_platform_card = insert(:stripe_platform_card, user: user)
    stripe_platform_customer = insert(:stripe_platform_customer, user: user)
    user_category = insert(:user_category, user: user)
    user_role = insert(:user_role, user: user)
    user_skill = insert(:user_skill, user: user)
    project_user = insert(:project_user, user: user)

    host = Application.get_env(:code_corps, :asset_host)
    intercom_user_hash = UserView.intercom_user_hash(user, %Plug.Conn{})

    user = CodeCorpsWeb.UserController.preload(user)
    rendered_json = render(UserView, "show.json-api", data: user)

    expected_json = %{
      "data" => %{
        "id" => user.id |> Integer.to_string,
        "type" => "user",
        "attributes" => %{
          "admin" => user.admin,
          "biography" => user.biography,
          "cloudinary-public-id" => nil,
          "email" => "",
          "first-name" => "First",
          "github-avatar-url" => "foo",
          "github-id" => 123,
          "github-username" => "githubuser",
          "inserted-at" => user.inserted_at,
          "intercom-user-hash" => intercom_user_hash,
          "last-name" => "Last",
          "name" => "First Last",
          "photo-large-url" => "#{host}/icons/user_default_large_blue.png",
          "photo-thumb-url" => "#{host}/icons/user_default_thumb_blue.png",
          "sign-up-context" => "default",
          "state" => "signed_up",
          "state-transition" => nil,
          "twitter" => user.twitter,
          "username" => user.username,
          "updated-at" => user.updated_at,
          "website" => user.website
        },
        "relationships" => %{
          "categories" => %{
            "data" => [
              %{"id" => user_category.category_id |> Integer.to_string, "type" => "category"}
            ]
          },
          "github-app-installations" => %{
            "data" => [
              %{"id" => github_app_installation.id |> Integer.to_string, "type" => "github-app-installation"}
            ]
          },
          "project-users" => %{
            "data" => [
              %{"id" => project_user.id |> Integer.to_string, "type" => "project-user"}
            ]
          },
          "slugged-route" => %{
            "data" => %{"id" => slugged_route.id |> Integer.to_string, "type" => "slugged-route"}
          },
          "stripe-connect-subscriptions" => %{
            "data" => [
              %{"id" => stripe_connect_subscription.id |> Integer.to_string, "type" => "stripe-connect-subscription"}
            ]
          },
          "stripe-platform-card" => %{
            "data" => %{"id" => stripe_platform_card.id |> Integer.to_string, "type" => "stripe-platform-card"}
          },
          "stripe-platform-customer" => %{
            "data" => %{"id" => stripe_platform_customer.id |> Integer.to_string, "type" => "stripe-platform-customer"}
          },
          "user-categories" => %{
            "data" => [
              %{"id" => user_category.id |> Integer.to_string, "type" => "user-category"}
            ]
          },
          "user-roles" => %{
            "data" => [
              %{"id" => user_role.id |> Integer.to_string, "type" => "user-role"}
            ]
          },
          "user-skills" => %{
            "data" => [
              %{"id" => user_skill.id |> Integer.to_string, "type" => "user-skill"}
            ]
          }
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end

  test "renders email when user is the authenticated user" do
    user = insert(:user)

    conn =
      ConnTest.build_conn()
      |> Conn.assign(:current_user, user)

    user = CodeCorpsWeb.UserController.preload(user)
    rendered_json = render(UserView, "show.json-api", data: user, conn: conn)
    assert rendered_json["data"]["attributes"]["email"] == user.email
  end

  test "renders email for only the authenticated user when rendering list" do
    users = insert_list(4, :user)
    auth_user = users |> List.last

    conn =
      ConnTest.build_conn()
      |> Conn.assign(:current_user, auth_user)

    users = CodeCorpsWeb.UserController.preload(users)
    rendered_json = render(UserView, "show.json-api", data: users, conn: conn)

    emails =
      rendered_json["data"]
      |> Enum.map(&Map.get(&1, "attributes"))
      |> Enum.map(&Map.get(&1, "email"))
      |> Enum.filter(fn(email) -> email != "" end)

    assert emails == [auth_user.email]
  end

  test "renders first and last name as name" do
    user = build(:user, id: 1, first_name: "First", last_name: "Last")

    assert render_user_json(user)["data"]["attributes"]["name"] == "First Last"
  end

  test "renders first name only as name" do
    user = build(:user, id: 1, first_name: "", last_name: "Last")

    assert render_user_json(user)["data"]["attributes"]["name"] == "Last"
  end

  test "renders last name only as name" do
    user = build(:user, id: 1, first_name: "First", last_name: "")

    assert render_user_json(user)["data"]["attributes"]["name"] == "First"
  end

  test "renders nil name if first or last name blank" do
    user = build(:user, id: 1, first_name: "", last_name: "")

    assert render_user_json(user)["data"]["attributes"]["name"] == nil

    user = build(:user, id: 1, first_name: nil, last_name: nil)

    assert render_user_json(user)["data"]["attributes"]["name"] == nil
  end

  defp render_user_json(user) do
    user = CodeCorpsWeb.UserController.preload(user)

    conn =
      ConnTest.build_conn()
      |> Conn.assign(:current_user, user)

    render(UserView, "show.json-api", data: user, conn: conn)
  end
end

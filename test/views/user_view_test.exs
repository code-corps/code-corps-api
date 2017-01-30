defmodule CodeCorps.UserViewTest do
  use CodeCorps.ViewCase

  alias Phoenix.ConnTest
  alias Plug.Conn

  test "renders all attributes and relationships properly" do
    user = insert(:user, first_name: "First", last_name: "Last")
    organization_membership = insert(:organization_membership, member: user)
    slugged_route = insert(:slugged_route, user: user)
    stripe_connect_subscription = insert(:stripe_connect_subscription, user: user)
    stripe_platform_card = insert(:stripe_platform_card, user: user)
    stripe_platform_customer = insert(:stripe_platform_customer, user: user)
    user_category = insert(:user_category, user: user)
    user_role = insert(:user_role, user: user)
    user_skill = insert(:user_skill, user: user)

    rendered_json = render(CodeCorps.UserView, "show.json-api", data: user)

    expected_json = %{
      "data" => %{
        "id" => user.id |> Integer.to_string,
        "type" => "user",
        "attributes" => %{
          "biography" => user.biography,
          "email" => "",
          "first-name" => "First",
          "inserted-at" => user.inserted_at,
          "last-name" => "Last",
          "name" => "First Last",
          "photo-large-url" => CodeCorps.UserPhoto.url({user.photo, user}, :large),
          "photo-thumb-url" => CodeCorps.UserPhoto.url({user.photo, user}, :thumb),
          "state" => "signed_up",
          "state-transition" => nil,
          "twitter" => user.twitter,
          "username" => user.username,
          "updated-at" => user.updated_at,
          "website" => user.website
        },
        "relationships" => %{
          "organization-memberships" => %{
            "data" => [
              %{"id" => organization_membership.id |> Integer.to_string, "type" => "organization-membership"}
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
      ConnTest.build_conn
      |> Conn.assign(:current_user, user)

    rendered_json = render(CodeCorps.UserView, "show.json-api", data: user, conn: conn)
    assert rendered_json["data"]["attributes"]["email"] == user.email
  end

  test "renders email for only the authenticated user when rendering list" do
    users = insert_list(4, :user)
    auth_user = users |> List.last

    conn =
      ConnTest.build_conn
      |> Conn.assign(:current_user, auth_user)

    rendered_json = render(CodeCorps.UserView, "show.json-api", data: users, conn: conn)

    emails =
      rendered_json["data"]
      |> Enum.map(&Map.get(&1, "attributes"))
      |> Enum.map(&Map.get(&1, "email"))
      |> Enum.filter(fn(email) -> email != "" end)

    assert emails == [auth_user.email]
  end

  test "renders first and last name as name" do
    user = build(:user, first_name: "First", last_name: "Last")

    assert render_user_json(user)["data"]["attributes"]["name"] == "First Last"
  end

  test "renders first name only as name" do
    user = build(:user, first_name: "", last_name: "Last")

    assert render_user_json(user)["data"]["attributes"]["name"] == "Last"
  end

  test "renders last name only as name" do
    user = build(:user, first_name: "First", last_name: "")

    assert render_user_json(user)["data"]["attributes"]["name"] == "First"
  end

  test "renders nil name if first or last name blank" do
    user = build(:user, first_name: "", last_name: "")

    assert render_user_json(user)["data"]["attributes"]["name"] == nil

    user = build(:user, first_name: nil, last_name: nil)

    assert render_user_json(user)["data"]["attributes"]["name"] == nil
  end

  defp render_user_json(user) do
    conn =
      ConnTest.build_conn
      |> Conn.assign(:current_user, user)

    render(CodeCorps.UserView, "show.json-api", data: user, conn: conn)
  end
end

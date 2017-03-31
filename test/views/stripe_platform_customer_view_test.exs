defmodule CodeCorps.Web.StripePlatformCustomerViewTest do
  use CodeCorps.Web.ViewCase

  alias Phoenix.ConnTest
  alias Plug.Conn

  test "renders all attributes and relationships properly" do
    user = insert(:user)
    stripe_platform_customer = insert(:stripe_platform_customer, id_from_stripe: "some_id", email: "email", user: user)

    rendered_json =  render(CodeCorps.Web.StripePlatformCustomerView, "show.json-api", data: stripe_platform_customer)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "email" => "",
          "created" => stripe_platform_customer.created,
          "currency" => stripe_platform_customer.currency,
          "delinquent" => stripe_platform_customer.delinquent,
          "id-from-stripe" => "",
          "inserted-at" => stripe_platform_customer.inserted_at,
          "updated-at" => stripe_platform_customer.updated_at
        },
        "id" => stripe_platform_customer.id |> Integer.to_string,
        "relationships" => %{
          "user" => %{
            "data" => %{"id" => user.id |> Integer.to_string, "type" => "user"}
          }
        },
        "type" => "stripe-platform-customer",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end

  test "renders email and id_from_stripe when user is the authenticated user" do
    user = insert(:user)
    stripe_platform_customer = insert(:stripe_platform_customer, id_from_stripe: "some_id", email: "email", user: user)

    conn =
      ConnTest.build_conn
      |> Conn.assign(:current_user, user)
    rendered_json = render(CodeCorps.Web.StripePlatformCustomerView, "show.json-api", data: stripe_platform_customer, conn: conn)
    assert rendered_json["data"]["attributes"]["email"] == stripe_platform_customer.email
    assert rendered_json["data"]["attributes"]["id-from-stripe"] == stripe_platform_customer.id_from_stripe
  end

  test "renders email and id_from_stripe for only the authenticated user when rendering list" do
    stripe_platform_customers = insert_list(4, :stripe_platform_customer)
    auth_customer = stripe_platform_customers |> List.last

    conn =
      ConnTest.build_conn
      |> Conn.assign(:current_user, auth_customer.user)

    rendered_json = render(CodeCorps.Web.StripePlatformCustomerView, "show.json-api", data: stripe_platform_customers, conn: conn)

    emails =
      rendered_json["data"]
      |> Enum.map(&Map.get(&1, "attributes"))
      |> Enum.map(&Map.get(&1, "email"))
      |> Enum.filter(fn(email) -> email != "" end)

    assert emails == [auth_customer.email]

    stripe_ids =
      rendered_json["data"]
      |> Enum.map(&Map.get(&1, "attributes"))
      |> Enum.map(&Map.get(&1, "id-from-stripe"))
      |> Enum.filter(fn(id_from_stripe) -> id_from_stripe != "" end)

    assert stripe_ids == [auth_customer.id_from_stripe]
  end
end

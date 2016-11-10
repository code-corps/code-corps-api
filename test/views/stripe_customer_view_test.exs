defmodule CodeCorps.StripeCustomerViewTest do
  use CodeCorps.ConnCase, async: true

  import Phoenix.View, only: [render: 3]

  test "renders all attributes and relationships properly" do
    user = insert(:user)
    stripe_customer = insert(:stripe_customer, id_from_stripe: "some_id", email: "email", user: user)

    rendered_json =  render(CodeCorps.StripeCustomerView, "show.json-api", data: stripe_customer)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "email" => "",
          "created" => stripe_customer.created,
          "currency" => stripe_customer.currency,
          "delinquent" => stripe_customer.delinquent,
          "id-from-stripe" => "",
          "inserted-at" => stripe_customer.inserted_at,
          "updated-at" => stripe_customer.updated_at
        },
        "id" => stripe_customer.id |> Integer.to_string,
        "relationships" => %{
          "user" => %{
            "data" => %{"id" => user.id |> Integer.to_string, "type" => "user"}
          }
        },
        "type" => "stripe-customer",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end

  test "renders email and id_from_stripe when user is the authenticated user" do
    user = insert(:user)
    stripe_customer = insert(:stripe_customer, id_from_stripe: "some_id", email: "email", user: user)

    conn = Phoenix.ConnTest.build_conn |> assign(:current_user, user)
    rendered_json = render(CodeCorps.StripeCustomerView, "show.json-api", data: stripe_customer, conn: conn)
    assert rendered_json["data"]["attributes"]["email"] == stripe_customer.email
    assert rendered_json["data"]["attributes"]["id-from-stripe"] == stripe_customer.id_from_stripe
  end

  test "renders email and id_from_stripe for only the authenticated user when rendering list" do
    stripe_customers = insert_list(4, :stripe_customer)
    auth_customer = stripe_customers |> List.last

    conn = Phoenix.ConnTest.build_conn |> assign(:current_user, auth_customer.user)
    rendered_json = render(CodeCorps.StripeCustomerView, "show.json-api", data: stripe_customers, conn: conn)

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

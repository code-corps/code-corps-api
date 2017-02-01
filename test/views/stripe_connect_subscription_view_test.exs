defmodule CodeCorps.StripeConnectSubscriptionViewTest do
  use CodeCorps.ViewCase

  test "renders all attributes and relationships properly" do
    project = insert(:project)
    plan = insert(:stripe_connect_plan, project: project)
    user = insert(:user)
    subscription = insert(:stripe_connect_subscription, stripe_connect_plan: plan, user: user)

    rendered_json =  render(CodeCorps.StripeConnectSubscriptionView, "show.json-api", data: subscription)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "inserted-at" => subscription.inserted_at,
          "quantity" => subscription.quantity,
          "updated-at" => subscription.updated_at
        },
        "id" => subscription.id |> Integer.to_string,
        "relationships" => %{
          "project" => %{
            "data" => %{"id" => project.id |> Integer.to_string, "type" => "project"}
          },
          "user" => %{
            "data" => %{"id" => user.id |> Integer.to_string, "type" => "user"}
          }
        },
        "type" => "stripe-connect-subscription",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

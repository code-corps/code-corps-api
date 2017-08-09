defmodule CodeCorpsWeb.StripeConnectPlanViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    project = insert(:project)
    plan = insert(:stripe_connect_plan, project: project)

    rendered_json =  render(CodeCorpsWeb.StripeConnectPlanView, "show.json-api", data: plan)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "amount" => plan.amount,
          "created" => plan.created,
          "id-from-stripe" => plan.id_from_stripe,
          "inserted-at" => plan.inserted_at,
          "name" => plan.name,
          "updated-at" => plan.updated_at
        },
        "id" => plan.id |> Integer.to_string,
        "relationships" => %{
          "project" => %{
            "data" => %{"id" => project.id |> Integer.to_string, "type" => "project"}
          }
        },
        "type" => "stripe-connect-plan",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

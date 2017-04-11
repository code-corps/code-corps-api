defmodule CodeCorps.Web.DonationGoalViewTest do
  use CodeCorps.Web.ViewCase

  test "renders all attributes and relationships properly" do
    project = insert(:project)
    plan = insert(:stripe_connect_plan, project: project)
    insert(:stripe_connect_subscription, stripe_connect_plan: plan, quantity: 100)
    donation_goal = insert(:donation_goal, project: project, amount: 500)
    CodeCorps.Services.DonationGoalsService.update_related_goals(donation_goal)

    rendered_json = render(CodeCorps.Web.DonationGoalView, "show.json-api", data: donation_goal)

    expected_json = %{
      "data" => %{
        "id" => donation_goal.id |> Integer.to_string,
        "type" => "donation-goal",
        "attributes" => %{
          "achieved" => false,
          "amount" => donation_goal.amount,
          "current" => donation_goal.current,
          "description" => donation_goal.description
        },
        "relationships" => %{
          "project" => %{
            "data" => %{
              "id" => donation_goal.project_id |> Integer.to_string,
              "type" => "project"
            }
          }
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert expected_json == rendered_json
  end
end

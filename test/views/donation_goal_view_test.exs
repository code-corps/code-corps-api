defmodule CodeCorps.DonationGoalViewTest do
  use CodeCorps.ConnCase, async: true

  import Phoenix.View, only: [render: 3]

  test "renders all attributes and relationships properly" do
    project = insert(:project)
    donation_goal = insert(:donation_goal, project: project)

    rendered_json = render(CodeCorps.DonationGoalView, "show.json-api", data: donation_goal)

    expected_json = %{
      "data" => %{
        "id" => donation_goal.id |> Integer.to_string,
        "type" => "donation-goal",
        "attributes" => %{
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

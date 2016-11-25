defmodule CodeCorps.ProjectViewTest do
  use CodeCorps.ConnCase, async: true

  import Phoenix.View, only: [render: 3]

  def set_current_donation_goal(project, donation_goal) do
    %{project | current_donation_goal_id: donation_goal.id}
  end

  test "renders all attributes and relationships properly" do
    organization = insert(:organization)
    project = insert(:project, organization: organization)

    donation_goal = insert(:donation_goal, project: project)
    project_category = insert(:project_category, project: project)
    project_skill = insert(:project_skill, project: project)
    stripe_connect_plan = insert(:stripe_connect_plan, project: project)
    task = insert(:task, project: project)

    project = project |> set_current_donation_goal(donation_goal)

    rendered_json = render(CodeCorps.ProjectView, "show.json-api", data: project)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "description" => project.description,
          "icon-large-url" => CodeCorps.ProjectIcon.url({project.icon, project}, :large),
          "icon-thumb-url" => CodeCorps.ProjectIcon.url({project.icon, project}, :thumb),
          "inserted-at" => project.inserted_at,
          "long-description-body" => project.long_description_body,
          "long-description-markdown" => project.long_description_markdown,
          "slug" => project.slug,
          "title" => project.title,
          "updated-at" => project.updated_at,
        },
        "id" => project.id |> Integer.to_string,
        "relationships" => %{
          "current-donation-goal" => %{
            "data" => %{
              "id" => donation_goal.id |> Integer.to_string,
              "type" => "donation-goal"
            }
          },
          "donation-goals" => %{"data" => [
            %{
              "id" => donation_goal.id |> Integer.to_string,
              "type" => "donation-goal"
            }
          ]},
          "organization" => %{
            "data" => %{
              "id" => organization.id |> Integer.to_string,
              "type" => "organization"
            }
          },
          "project-categories" => %{
            "data" => [
              %{
                "id" => project_category.id |> Integer.to_string,
                "type" => "project-category"
              }
            ]
          },
          "project-skills" => %{
            "data" => [
              %{
                "id" => project_skill.id |> Integer.to_string,
                "type" => "project-skill"
              }
            ]
          },
          "stripe-connect-plan" => %{
            "data" => %{
              "id" => stripe_connect_plan.id |> Integer.to_string,
              "type" => "stripe-connect-plan"
            }
          },
          "tasks" => %{
            "data" => [
              %{
                "id" => task.id |> Integer.to_string,
                "type" => "task"
              }
            ]
          }
        },
        "type" => "project",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

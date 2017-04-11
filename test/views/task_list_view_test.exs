defmodule CodeCorps.Web.TaskListViewTest do
  use CodeCorps.Web.ViewCase

  test "renders all attributes and relationships properly" do
    project = insert(:project)
    task_list = insert(:task_list, order: 1000, project: project)
    task = insert(:task, order: 1000, task_list: task_list)

    rendered_json =  render(CodeCorps.Web.TaskListView, "show.json-api", data: task_list)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "inbox" => task_list.inbox,
          "name" => task_list.name,
          "order" => 1000,
          "inserted-at" => task_list.inserted_at,
          "updated-at" => task_list.updated_at,
        },
        "id" => task_list.id |> Integer.to_string,
        "relationships" => %{
          "project" => %{
            "data" => %{
              "id" => task_list.project_id |> Integer.to_string,
              "type" => "project"
            }
          },
          "tasks" => %{
            "data" => [%{
              "id" => task.id |> Integer.to_string,
              "type" => "task"
            }]
          }
        },
        "type" => "task-list",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

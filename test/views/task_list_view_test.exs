defmodule CodeCorps.TaskListViewTest do
  use CodeCorps.ConnCase, async: true

  import Phoenix.View, only: [render: 3]

  test "renders all attributes and relationships properly" do
    project = insert(:project)
    task_list_a = insert(:task_list, rank: 1000, project: project)
    task_list_b = insert(:task_list, rank: 500, project: project)
    task = insert(:task, rank: 1000, task_list: task_list_a)

    rendered_json =  render(CodeCorps.TaskListView, "show.json-api", data: [task_list_a, task_list_b])

    expected_json = %{
      "data" => [%{
        "attributes" => %{
          "name" => task_list_a.name,
          "rank" => 1000,
          "inserted-at" => task_list_a.inserted_at,
          "updated-at" => task_list_a.updated_at,
        },
        "id" => task_list_a.id |> Integer.to_string,
        "relationships" => %{
          "project" => %{
            "data" => %{
              "id" => task_list_a.project_id |> Integer.to_string,
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
      }, %{
        "attributes" => %{
          "name" => task_list_b.name,
          "rank" => 500,
          "inserted-at" => task_list_b.inserted_at,
          "updated-at" => task_list_b.updated_at,
        },
        "id" => task_list_b.id |> Integer.to_string,
        "relationships" => %{
          "project" => %{
            "data" => %{
              "id" => task_list_b.project_id |> Integer.to_string,
              "type" => "project"
            }
          },
          "tasks" => %{
            "data" => []
          }
        },
        "type" => "task-list"
      }],
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

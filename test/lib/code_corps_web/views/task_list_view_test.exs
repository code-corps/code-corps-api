defmodule CodeCorpsWeb.TaskListViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    project = insert(:project)
    task_list = insert(:task_list, order: 1000, project: project)
    task = insert(:task, order: 1000, task_list: task_list)

    task_list = CodeCorpsWeb.TaskListController.preload(task_list)
    rendered_json =  render(CodeCorpsWeb.TaskListView, "show.json-api", data: task_list)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "done" => task_list.done,
          "inbox" => task_list.inbox,
          "name" => task_list.name,
          "order" => 1000,
          "pull-requests" => task_list.pull_requests,
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
      },
      "included" => [%{
        "attributes" => %{
          "archived" => task.archived, 
          "body" => task.body, 
          "created-at" => task.created_at, 
          "created-from" => task.created_from, 
          "inserted-at" => task.inserted_at, 
          "markdown" => task.markdown, 
          "modified-at" => task.modified_at, 
          "modified-from" => task.modified_from, 
          "number" => task.number, 
          "order" => task.order, 
          "status" => task.status, 
          "title" => task.title, 
          "updated-at" => task.updated_at
        },
        "id" => task.id |> Integer.to_string, 
        "type" => "task"
      }]
    }

    assert rendered_json == expected_json
  end
end

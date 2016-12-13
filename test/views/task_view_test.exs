defmodule CodeCorps.TaskViewTest do
  use CodeCorps.ConnCase, async: true

  import Phoenix.View, only: [render: 3]

  test "renders all attributes and relationships properly" do
    task = insert(:task, rank: 1000)
    comment = insert(:comment, task: task)

    rendered_json =  render(CodeCorps.TaskView, "show.json-api", data: task)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "body" => task.body,
          "inserted-at" => task.inserted_at,
          "markdown" => task.markdown,
          "number" => task.number,
          "status" => task.status,
          "state" => task.state,
          "task-type" => task.task_type,
          "title" => task.title,
          "updated-at" => task.updated_at,
          "rank" => task.rank
        },
        "id" => task.id |> Integer.to_string,
        "relationships" => %{
          "comments" => %{
            "data" => [
              %{
                "id" => comment.id |> Integer.to_string,
                "type" => "comment"
              }
            ]
          },
          "project" => %{
            "data" => %{
              "id" => task.project_id |> Integer.to_string,
              "type" => "project"
            }
          },
          "user" => %{
            "data" => %{
              "id" => task.user_id |> Integer.to_string,
              "type" => "user"
            }
          },
          "task-list" => %{
            "data" => %{
              "id" => task.task_list_id |> Integer.to_string,
              "type" => "task-list"
            }
          }
        },
        "type" => "task",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

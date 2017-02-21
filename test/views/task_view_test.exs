defmodule CodeCorps.TaskViewTest do
  use CodeCorps.ViewCase

  test "renders all attributes and relationships properly" do
    task = insert(:task, order: 1000)
    comment = insert(:comment, task: task)
    task_skill = insert(:task_skill, task: task)
    user_task = insert(:user_task, task: task)

    rendered_json =  render(CodeCorps.TaskView, "show.json-api", data: task)

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "body" => task.body,
          "inserted-at" => task.inserted_at,
          "markdown" => task.markdown,
          "number" => task.number,
          "order" => task.order,
          "status" => task.status,
          "state" => task.state,
          "title" => task.title,
          "updated-at" => task.updated_at
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
          "task-skills" => %{
            "data" => [
              %{
                "id" => task_skill.id |> Integer.to_string,
                "type" => "task-skill"
              }
            ]
          },
          "user" => %{
            "data" => %{
              "id" => task.user_id |> Integer.to_string,
              "type" => "user"
            }
          },
          "user-task" => %{
            "data" => %{
              "id" => user_task.id |> Integer.to_string,
              "type" => "user-task"
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

defmodule CodeCorpsWeb.CommentViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    task = insert(:task)
    user = insert(:user)
    comment = insert(:comment, user: user, task: task)

    rendered_json = render(CodeCorpsWeb.CommentView, "show.json-api", data: comment)

    expected_json = %{
      "data" => %{
        "id" => comment.id |> Integer.to_string,
        "type" => "comment",
        "attributes" => %{
          "body" => comment.body,
          "created-at" => task.created_at,
          "created-from" => task.created_from,
          "inserted-at" => comment.inserted_at,
          "markdown" => comment.markdown,
          "modified-at" => task.modified_at,
          "modified-from" => task.modified_from,
          "updated-at" => comment.updated_at
        },
        "relationships" => %{
          "task" => %{
            "data" => %{
              "id" => comment.task_id |> Integer.to_string,
              "type" => "task"
            }
          },
          "user" => %{
            "data" => %{
              "id" => comment.user_id |> Integer.to_string,
              "type" => "user"
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

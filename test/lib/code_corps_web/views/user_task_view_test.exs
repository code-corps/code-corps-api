defmodule CodeCorpsWeb.UserTaskViewTest do
  @moduledoc false

  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    user_task = insert(:user_task)

    rendered_json = render(CodeCorpsWeb.UserTaskView, "show.json-api", data: user_task)

    expected_json = %{
      "data" => %{
        "id" => user_task.id |> Integer.to_string,
        "type" => "user-task",
        "attributes" => %{},
        "relationships" => %{
          "task" => %{
            "data" => %{"id" => user_task.task_id |> Integer.to_string, "type" => "task"}
          },
          "user" => %{
            "data" => %{"id" => user_task.user_id |> Integer.to_string, "type" => "user"}
          }
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

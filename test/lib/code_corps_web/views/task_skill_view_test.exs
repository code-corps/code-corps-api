defmodule CodeCorpsWeb.TaskSkillViewTest do
  @moduledoc false

  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    task_skill = insert(:task_skill)

    rendered_json = render(CodeCorpsWeb.TaskSkillView, "show.json-api", data: task_skill)

    expected_json = %{
      "data" => %{
        "id" => task_skill.id |> Integer.to_string,
        "type" => "task-skill",
        "attributes" => %{},
        "relationships" => %{
          "task" => %{
            "data" => %{"id" => task_skill.task_id |> Integer.to_string, "type" => "task"}
          },
          "skill" => %{
            "data" => %{"id" => task_skill.skill_id |> Integer.to_string, "type" => "skill"}
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

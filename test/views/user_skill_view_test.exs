defmodule CodeCorps.UserSkillViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    db_user_skill = insert(:user_skill)

    user_skill =
      CodeCorps.UserSkill
      |> Repo.get(db_user_skill.id)
      |> Repo.preload([:user, :skill])

    rendered_json = render(CodeCorps.UserSkillView, "show.json-api", data: user_skill)

    expected_json = %{
      data: %{
        id: user_skill.id |> Integer.to_string,
        type: "user-skill",
        attributes: %{},
        relationships: %{
          "skill" => %{
            data: %{id: user_skill.skill_id |> Integer.to_string, type: "skill"}
          },
          "user" => %{
            data: %{id: user_skill.user_id |> Integer.to_string, type: "user"}
          }
        }
      },
      jsonapi: %{
        version: "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end

defmodule CodeCorps.UserSkillControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.UserSkill
  alias CodeCorps.Repo

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp attributes do
    %{}
  end

  defp relationships(user, skill) do
    %{
      "user" => %{
        "data" => %{
          "type" => "user",
          "id" => user.id
        }
      },
      "skill" => %{
        "data" => %{
          "type" => "skill",
          "id" => skill.id
        }
      },
    }
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_skill_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "filters resources on index", %{conn: conn} do
    elixir = insert(:skill, title: "Elixir")
    phoenix = insert(:skill, title: "Phoenix")
    rails = insert(:skill, title: "Rails")

    user = insert(:user)
    user_skill_1 = insert(:user_skill, user: user, skill: elixir)
    user_skill_2 = insert(:user_skill, user: user, skill: phoenix)
    insert(:user_skill, user: user, skill: rails)

    conn = get conn, "user-skills/?filter[id]=#{user_skill_1.id},#{user_skill_2.id}"
    data = json_response(conn, 200)["data"]
    [first_result, second_result | _] = data
    assert length(data) == 2
    assert first_result["id"] == "#{user_skill_1.id}"
    assert second_result["id"] == "#{user_skill_2.id}"
  end

  test "shows chosen resource", %{conn: conn} do
    skill = insert(:skill)
    user = insert(:user)
    user_skill = insert(:user_skill, user: user, skill: skill)
    conn = get conn, user_skill_path(conn, :show, user_skill)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{user_skill.id}"
    assert data["type"] == "user-skill"
    assert data["relationships"]["user"]["data"]["id"] == "#{user.id}"
    assert data["relationships"]["skill"]["data"]["id"] == "#{skill.id}"
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_skill_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    user = insert(:user)
    skill = insert(:skill, title: "test-skill")

    conn = post conn, user_skill_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "user-skill",
        "attributes" => attributes,
        "relationships" => relationships(user, skill)
      }
    }

    json = json_response(conn, 201)

    id = json["data"]["id"] |> String.to_integer
    user_skill = UserSkill |> Repo.get!(id)

    assert json["data"]["id"] == "#{user_skill.id}"
    assert json["data"]["type"] == "user-skill"
    assert json["data"]["relationships"]["user"]["data"]["id"] == "#{user.id}"
    assert json["data"]["relationships"]["skill"]["data"]["id"] == "#{skill.id}"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_skill_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "user-skill",
        "attributes" => attributes,
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes resource", %{conn: conn} do
    skill = insert(:skill, title: "test-skill")
    user = insert(:user)
    user_skill = insert(:user_skill, user: user, skill: skill)
    response = delete conn, user_skill_path(conn, :delete, user_skill)

    assert response.status == 204
  end
end

defmodule CodeCorps.RoleSkillControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.RoleSkill
  alias CodeCorps.Repo

  @valid_attrs %{}
  @invalid_attrs %{}

  setup do
    conn = %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end
  
  defp attributes do 
    project = Repo.insert!(%CodeCorps.Project{})
    skill = Repo.insert!(%CodeCorps.Skill{})
  end

  defp relationships(role, skill) do 
    %{
      "role" => %{
        "data" => %{
          "type" => "role",
          "id" => role.id
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
    conn = get conn, role_skill_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "filters resources on index", %{conn: conn} do
    elixir = insert_skill(%{title: "Elixir"})
    phoenix = insert_skill(%{title: "Phoenix"})
    rails = insert_skill(%{title: "Rails"})

    role = insert_role()
    role_skill_1 = insert_role_skill(%{role_id: role.id, skill_id: elixir.id})
    role_skill_2 = insert_role_skill(%{role_id: role.id, skill_id: phoenix.id})
    insert_role_skill(%{role_id: role.id, skill_id: rails.id})

    conn = get conn, "role-skills/?filter[id]=#{role_skill_1.id},#{role_skill_2.id}"
    data = json_response(conn, 200)["data"]
    [first_result, second_result | _] = data
    assert length(data) == 2
    assert first_result["id"] == "#{role_skill_1.id}"
    assert first_result["attributes"] == %{}
    assert first_result["relationships"]["role"]["data"]["id"] == "#{role.id}"
    assert first_result["relationships"]["role"]["data"]["type"] == "role" 
    assert first_result["relationships"]["skill"]["data"]["id"] == "#{elixir.id}"
    assert first_result["relationships"]["skill"]["data"]["type"] == "skill" 
    assert second_result["id"] == "#{role_skill_2.id}"
    assert second_result["attributes"] == %{}
    assert second_result["relationships"]["role"]["data"]["id"] == "#{role.id}"
    assert second_result["relationships"]["role"]["data"]["type"] == "role" 
    assert second_result["relationships"]["skill"]["data"]["id"] == "#{phoenix.id}"
    assert second_result["relationships"]["skill"]["data"]["type"] == "skill" 
  end

  test "shows chosen resource", %{conn: conn} do
    skill = insert_skill()
    role = insert_role()
    role_skill = insert_role_skill(%{role_id: role.id, skill_id: skill.id})
    conn = get conn, role_skill_path(conn, :show, role_skill)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{role_skill.id}"
    assert data["type"] == "role-skill"
    assert data["attributes"] == %{}
    assert data["relationships"]["role"]["data"]["id"] == "#{role.id}"
    assert data["relationships"]["role"]["data"]["type"] == "role"
    assert data["relationships"]["skill"]["data"]["id"] == "#{skill.id}"
    assert data["relationships"]["skill"]["data"]["type"] == "skill"
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, role_skill_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    role = insert_role(%{name: "Frontend Developer"})
    skill = insert_skill(%{title: "test skill"})

    conn = post conn, role_skill_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "role-skill",
        "attributes" => attributes,
        "relationships" => relationships(role, skill)
      }
    }
    json = json_response(conn, 201)

    id = json["data"]["id"] |> String.to_integer
    role_skill = RoleSkill |> Repo.get!(id)

    assert json["data"]["id"] == "#{role_skill.id}"
    assert json["data"]["type"] == "role-skill"
    assert json["data"]["attributes"] == %{}
    assert json["data"]["relationships"]["role"]["data"]["id"] == "#{role.id}"
    assert json["data"]["relationships"]["role"]["data"]["type"] == "role"
    assert json["data"]["relationships"]["skill"]["data"]["id"] == "#{skill.id}"
    assert json["data"]["relationships"]["skill"]["data"]["type"] == "skill"

  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, role_skill_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "role-skill",
        "attributes" => attributes
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes resource", %{conn: conn} do
    skill = insert_skill(%{title: "test-skill"})
    role = insert_role(%{name: "Frontend Developer"})
    role_skill = insert_role_skill(%{role_id: role.id, skill_id: skill.id})
    conn = delete conn, role_skill_path(conn, :delete, role_skill)

    assert response(conn, 204)
    refute Repo.get(RoleSkill, role_skill.id)
    assert Repo.get(CodeCorps.Role, role.id)
    assert Repo.get(CodeCorps.Skill, skill.id)
  end
end

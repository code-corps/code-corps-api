defmodule CodeCorps.ProjectSkillControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.ProjectSkill
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
  end
  
  defp relationships(project, skill) do 
    %{
      "project" => %{
        "data" => %{
          "type" => "project",
          "id" => project.id
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
    conn = get conn, project_skill_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "filters resources on index", %{conn: conn} do
    elixir = insert(:skill, title: "Elixir")
    phoenix = insert(:skill, title: "Phoenix")
    rails = insert(:skill, title: "Rails")

    project = insert(:project)
    project_skill_1 = insert(:project_skill, project: project, skill: elixir)
    project_skill_2 = insert(:project_skill, project: project, skill: phoenix)
    insert(:project_skill, project: project, skill: rails)

    conn = get conn, "project-skills/?filter[id]=#{project_skill_1.id},#{project_skill_2.id}"
    data = json_response(conn, 200)["data"]
    [first_result, second_result | _] = data
    assert length(data) == 2
    assert first_result["id"] == "#{project_skill_1.id}"
    assert first_result["relationships"]["project"]["data"]["id"] == "#{project.id}"
    assert first_result["relationships"]["project"]["data"]["type"] == "project" 
    assert first_result["relationships"]["skill"]["data"]["id"] == "#{elixir.id}"
    assert first_result["relationships"]["skill"]["data"]["type"] == "skill" 
    assert second_result["id"] == "#{project_skill_2.id}"
    assert second_result["relationships"]["project"]["data"]["id"] == "#{project.id}"
    assert second_result["relationships"]["project"]["data"]["type"] == "project" 
    assert second_result["relationships"]["skill"]["data"]["id"] == "#{phoenix.id}"
    assert second_result["relationships"]["skill"]["data"]["type"] == "skill" 
  end

  test "shows chosen resource", %{conn: conn} do
    skill = insert(:skill)
    project = insert(:project)
    project_skill = insert(:project_skill, project: project, skill: skill)
    conn = get conn, project_skill_path(conn, :show, project_skill)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{project_skill.id}"
    assert data["type"] == "project-skill"
    assert data["attributes"] == %{}
    assert data["relationships"]["project"]["data"]["id"] == "#{project.id}"
    assert data["relationships"]["project"]["data"]["type"] == "project"
    assert data["relationships"]["skill"]["data"]["id"] == "#{skill.id}"
    assert data["relationships"]["skill"]["data"]["type"] == "skill"
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, project_skill_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    project = insert(:project)
    skill = insert(:skill)

    conn = post conn, project_skill_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "project-skill",
        "attributes" => attributes,
        "relationships" => relationships(project, skill)
      }
    }
    json = json_response(conn, 201)

    id = json["data"]["id"] |> String.to_integer
    project_skill = ProjectSkill |> Repo.get!(id)

    assert json["data"]["id"] == "#{project_skill.id}"
    assert json["data"]["type"] == "project-skill"
    assert json["data"]["attributes"] == %{}
    assert json["data"]["relationships"]["project"]["data"]["id"] == "#{project.id}"
    assert json["data"]["relationships"]["project"]["data"]["type"] == "project"
    assert json["data"]["relationships"]["skill"]["data"]["id"] == "#{skill.id}"
    assert json["data"]["relationships"]["skill"]["data"]["type"] == "skill"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_skill_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "user-skill",
        "attributes" => attributes
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    project_skill = Repo.insert! %ProjectSkill{}
    conn = delete conn, project_skill_path(conn, :delete, project_skill)
    assert response(conn, 204)
    refute Repo.get(ProjectSkill, project_skill.id)
  end

end

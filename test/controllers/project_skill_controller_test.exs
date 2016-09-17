defmodule CodeCorps.ProjectSkillControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.ProjectSkill
  alias CodeCorps.Repo

  @attrs %{}

  defp build_payload, do: %{ "data" => %{"type" => "project-skill", "attributes" => %{}}}
  defp put_relationships(payload, project, skill) do
    relationships = build_relationships(project, skill)
    payload |> put_in(["data", "relationships"], relationships)
  end

  defp build_relationships(project, skill) do
    %{
      project: %{data: %{id: project.id}},
      skill: %{data: %{id: skill.id}}
    }
  end

  describe "index" do
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
      json =
        conn
        |> get("project-skills/?filter[id]=#{project_skill_1.id},#{project_skill_2.id}")
        |> json_response(200)
      data = json["data"]
      assert length(data) == 2
      [first_result, second_result | _] = data

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
  end

  describe "show" do
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
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      project = insert(:project)
      skill = insert(:skill)

      payload = build_payload |> put_relationships(project, skill)
      path = conn |> project_skill_path(:create)
      json = conn |> post(path, payload) |> json_response(201)

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

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      payload = build_payload
      path = conn |> project_skill_path(:create)
      json = conn |> post(path, payload) |> json_response(422)

      assert json["errors"] != %{}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> project_skill_path(:create)
      assert conn |> post(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      path = conn |> project_skill_path(:create)
      assert conn |> post(path) |> json_response(401)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes chosen resource", %{conn: conn} do
      project_skill = Repo.insert! %ProjectSkill{}
      path = conn |> project_skill_path(:delete, project_skill)
      assert conn |> delete(path) |> response(204)
      refute Repo.get(ProjectSkill, project_skill.id)
    end

    test "does not delete resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> project_skill_path(:delete, "id not important")
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      project_skill = insert(:project_skill)
      path = conn |> project_skill_path(:delete, project_skill)
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "renders page not found when id is nonexistent on delete", %{conn: conn} do
      path = conn |> project_skill_path(:delete, -1)
      assert conn |> delete(path) |> json_response(404)
    end
  end
end

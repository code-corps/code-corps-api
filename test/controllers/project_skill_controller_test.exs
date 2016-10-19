defmodule CodeCorps.ProjectSkillControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.ProjectSkill
  alias CodeCorps.Repo

  defp build_payload, do: %{ "data" => %{"type" => "project-skill", "attributes" => %{}}}

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

      [first_result, second_result | _rest] = json |> Map.get("data")

      first_result
      |> assert_result_id(project_skill_1.id)
      |> assert_jsonapi_relationship("project", project.id)
      |> assert_jsonapi_relationship("skill", elixir.id)

      second_result
      |> assert_result_id(project_skill_2.id)
      |> assert_jsonapi_relationship("project", project.id)
      |> assert_jsonapi_relationship("skill", phoenix.id)
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      skill = insert(:skill)
      project = insert(:project)
      project_skill = insert(:project_skill, project: project, skill: skill)
      conn = get conn, project_skill_path(conn, :show, project_skill)

      conn
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(project_skill.id)
      |> assert_jsonapi_relationship("project", project.id)
      |> assert_jsonapi_relationship("skill", skill.id)
      |> assert_attributes(%{})
    end

    test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      path = conn |> project_skill_path(:show, -1)
      assert conn |> get(path) |> json_response(:not_found)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      project = insert(:project, organization: organization)
      skill = insert(:skill)

      insert(:organization_membership, role: "admin", member: current_user, organization: organization)

      payload = build_payload |> put_relationships(project, skill)
      path = conn |> project_skill_path(:create)
      json = conn |> post(path, payload) |> json_response(201)

      id = json["data"]["id"] |> String.to_integer
      project_skill = ProjectSkill |> Repo.get(id)

      json
      |> Map.get("data")
      |> assert_result_id(project_skill.id)
      |> assert_jsonapi_relationship("project", project.id)
      |> assert_jsonapi_relationship("skill", skill.id)
      |> assert_attributes(%{})
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
    test "does not create resource and renders 401 when not authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      project = insert(:project, organization: organization)
      skill = insert(:skill)

      insert(:organization_membership, role: "contributor", member: current_user, organization: organization)

      payload = build_payload |> put_relationships(project, skill)

      path = conn |> project_skill_path(:create)
      assert conn |> post(path, payload) |> json_response(401)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes chosen resource", %{conn: conn} do
      project_skill = insert(:project_skill)
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

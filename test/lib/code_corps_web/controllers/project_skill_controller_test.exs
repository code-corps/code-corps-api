defmodule CodeCorpsWeb.ProjectSkillControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :project_skill

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [project_skill_1, project_skill_2] = insert_pair(:project_skill)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([project_skill_1.id, project_skill_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [project_skill_1, project_skill_2 | _] = insert_list(3, :project_skill)

      path = "project-skills/?filter[id]=#{project_skill_1.id},#{project_skill_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([project_skill_1.id, project_skill_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      skill = insert(:skill)
      project = insert(:project)
      project_skill = insert(:project_skill, project: project, skill: skill)

      conn
      |> request_show(project_skill)
      |> json_response(200)
      |> assert_id_from_response(project_skill.id)
    end

    test "renders 404 error when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      insert(:project_user, project: project, user: current_user, role: "owner")
      skill = insert(:skill)

      attrs = %{project: project, skill: skill}
      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag :authenticated
    test "renders 422 error when data is invalid", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      insert(:project_user, project: project, user: current_user, role: "owner")

      invalid_attrs = %{project: project}
      assert conn |> request_create(invalid_attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end
  end

  describe "delete" do
    @tag :authenticated
    test "deletes chosen resource", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      insert(:project_user, project: project, user: current_user, role: "owner")
      project_skill = insert(:project_skill, project: project)
      assert conn |> request_delete(project_skill) |> response(204)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_delete |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_delete |> json_response(403)
    end

    @tag :authenticated
    test "renders 404 when id is nonexistent on delete", %{conn: conn} do
      assert conn |> request_delete(:not_found) |> json_response(404)
    end
  end
end

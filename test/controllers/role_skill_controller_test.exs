defmodule CodeCorps.Web.RoleSkillControllerTest do
  use CodeCorps.ApiCase, resource_name: :role_skill

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [role_skill_1, role_skill_2] = insert_pair(:role_skill)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([role_skill_1.id, role_skill_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [role_skill_1, role_skill_2 | _] = insert_list(3, :role_skill)

      path = "role-skills/?filter[id]=#{role_skill_1.id},#{role_skill_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([role_skill_1.id, role_skill_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      role_skill = insert(:role_skill)

      conn
      |> request_show(role_skill)
      |> json_response(200)
      |> assert_id_from_response(role_skill.id)
    end

    test "renders 404", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      role = insert(:role)
      skill = insert(:skill)

      attrs = %{role: role, skill: skill}
      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag authenticated: :admin
    test "renders 422 when data is invalid", %{conn: conn} do
      invalid_attrs = %{}
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
    @tag authenticated: :admin
    test "deletes resource", %{conn: conn} do
      assert conn |> request_delete |> response(204)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_delete |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_delete |> json_response(403)
    end

    @tag :authenticated
    test "renders 404", %{conn: conn} do
      assert conn |> request_delete(:not_found) |> json_response(404)
    end
  end
end

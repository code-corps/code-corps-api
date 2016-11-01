defmodule CodeCorps.UserRoleControllerTest do
  use CodeCorps.ApiCase, resource_name: :user_role

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [user_role_1, user_role_2] = insert_pair(:user_role)

      conn
        |> request_index
        |> json_response(200)
        |> assert_ids_from_response([user_role_1.id, user_role_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [user_role_1, user_role_2 | _] = insert_list(3, :user_role)

      path = "user-roles/?filter[id]=#{user_role_1.id},#{user_role_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([user_role_1.id, user_role_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      user_role = insert(:user_role)
      conn
      |> request_show(user_role)
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(user_role.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      user = insert(:user)
      role = insert(:role)
      attrs = (%{user: user, role: role})
      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag authenticated: :admin
    test "does not create resource and renders 422 when data is invalid", %{conn: conn} do
      invalid_attrs = %{}
      assert conn |> request_create(invalid_attrs) |> json_response(422)
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create(%{}) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create(%{}) |>  json_response(403)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes resource", %{conn: conn} do
      assert conn |> request_delete |> response(204)
    end

    test "does not delete resource and renders 401 when unauthenticated", %{conn: conn} do
    assert conn |> request_delete |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_delete |> json_response(403)
    end

    @tag :authenticated
    test "renders page not found when id is nonexistent on delete", %{conn: conn} do
      assert conn |> request_delete(:not_found) |> json_response(404)
    end
  end
end

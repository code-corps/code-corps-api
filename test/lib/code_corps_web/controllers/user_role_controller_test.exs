defmodule CodeCorpsWeb.UserRoleControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :user_role

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
      |> assert_id_from_response(user_role.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      role = insert(:role)
      attrs = (%{user: current_user, role: role})
      assert conn |> request_create(attrs) |> json_response(201)

      user_id = current_user.id
      tracking_properties = %{
        role: role.name,
        role_id: role.id
      }
      assert_received {:track, ^user_id, "Added User Role", ^tracking_properties}
    end

    @tag :authenticated
    test "renders 422 when data is invalid", %{conn: conn, current_user: current_user} do
      role = build(:role)
      invalid_attrs = %{role: role, user: current_user}
      assert conn |> request_create(invalid_attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      role = insert(:role)
      user = insert(:user)
      attrs = %{role: role, user: user}

      assert conn |> request_create(attrs) |>  json_response(403)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes resource", %{conn: conn, current_user: current_user} do
      user_role = insert(:user_role)
      assert conn |> request_delete(user_role.id) |> response(204)

      user_id = current_user.id
      tracking_properties = %{
        role: user_role.role.name,
        role_id: user_role.role.id
      }
      assert_received {:track, ^user_id, "Removed User Role", ^tracking_properties}
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

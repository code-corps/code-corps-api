defmodule CodeCorps.UserRoleControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.UserRole
  alias CodeCorps.Repo

  defp build_payload, do: %{ "data" => %{"type" => "user-role", "attributes" => %{}}}
  defp put_relationships(payload, user, role) do
    relationships = build_relationships(user, role)
    payload |> put_in(["data", "relationships"], relationships)
  end

  defp build_relationships(user, role) do
    %{
      user: %{data: %{id: user.id}},
      role: %{data: %{id: role.id}}
    }
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      user = insert(:user)
      role = insert(:role)

      payload = build_payload |> put_relationships(user, role)
      path = conn |> user_role_path(:create)
      json = conn |> post(path, payload) |> json_response(201)

      id = json["data"]["id"] |> String.to_integer
      user_role = UserRole |> Repo.get!(id)

      assert json["data"]["id"] == "#{user_role.id}"
      assert json["data"]["type"] == "user-role"
      assert json["data"]["relationships"]["user"]["data"]["id"] == "#{user_role.user_id}"
      assert json["data"]["relationships"]["role"]["data"]["id"] == "#{user_role.role_id}"
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      payload = build_payload
      path = conn |> user_role_path(:create)
      json = conn |> post(path, payload) |> json_response(422)

      assert json["errors"] != %{}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> user_role_path(:create)
      assert conn |> post(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      path = conn |> user_role_path(:create)
      assert conn |> post(path, build_payload) |> json_response(401)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes resource", %{conn: conn} do
      user_role = insert(:user_role)

      path = conn |> user_role_path(:delete, user_role)
      assert conn |> delete(path) |> response(204)
    end

    test "does not delete resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> user_role_path(:delete, "id not important")
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      user_role = insert(:user_role)
      path = conn |> user_role_path(:delete, user_role)
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "renders page not found when id is nonexistent on delete", %{conn: conn} do
      path = conn |> user_role_path(:delete, -1)
      assert conn |> delete(path) |> json_response(404)
    end
  end
end

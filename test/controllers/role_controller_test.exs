defmodule CodeCorps.Web.RoleControllerTest do
  use CodeCorps.ApiCase, resource_name: :role

  @valid_attrs %{ability: "Backend Development", kind: "technology", name: "Backend Developer"}
  @invalid_attrs %{ability: "Juggling", kind: "circus", name: "Juggler"}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [role_1, role_2] = insert_pair(:role)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([role_1.id, role_2.id])
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(201)
    end

    @tag authenticated: :admin
    test "renders 422 when data is invalid", %{conn: conn} do
      assert conn |> request_create(@invalid_attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "enders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |>  json_response(403)
    end
  end
end

defmodule CodeCorpsWeb.OrganizationControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :organization

  @valid_attrs %{
    cloudinary_public_id: "foo",
    description: "Build a better future.",
    name: "Code Corps"
  }
  @invalid_attrs %{name: ""}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [organization_1, organization_2] = insert_pair(:organization)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([organization_1.id, organization_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [organization_1, organization_2 | _] = insert_list(3, :organization)

      path = "organizations/?filter[id]=#{organization_1.id},#{organization_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([organization_1.id, organization_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      organization = insert(:organization)

      conn
      |> request_show(organization)
      |> json_response(200)
      |> assert_id_from_response(organization.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid and invite exists", %{conn: conn, current_user: user} do
      insert(:organization_invite, code: "valid")
      attrs = Map.merge(@valid_attrs, %{owner: user, invite_code: "valid"})
      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag :authenticated
    test "renders 403 when data is valid but invite does not exist", %{conn: conn, current_user: user} do
      attrs = Map.merge(@valid_attrs, %{owner: user, invite_code: "invalid"})
      assert conn |> request_create(attrs) |> json_response(403)
    end

    @tag authenticated: :admin
    test "renders 422 when data is invalid", %{conn: conn} do
      assert conn |> request_create(@invalid_attrs) |> json_response(422)
    end

    @tag authenticated: :admin
    test "creates and renders resource when data is valid and user is admin", %{conn: conn, current_user: user} do
      attrs = Map.merge(@valid_attrs, %{owner: user})
      assert conn |> request_create(attrs) |> json_response(201)
    end

    test "renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when data is valid, but no invite and user not admin", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end
  end

  describe "update" do
    @tag authenticated: :admin
    test "updates and renders chosen resource when data is valid", %{conn: conn} do
      assert conn |> request_update(@valid_attrs) |> json_response(200)
    end

    @tag authenticated: :admin
    test "renders 422 when data is invalid", %{conn: conn} do
      assert conn |> request_update(@invalid_attrs) |> json_response(422)
    end

    test "renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_update |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_update |> json_response(403)
    end

    @tag :authenticated
    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_update(:not_found) |> json_response(404)
    end
  end
end

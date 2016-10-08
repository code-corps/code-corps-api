defmodule CodeCorps.CategoryControllerTest do
  use CodeCorps.ApiCase

  @valid_attrs %{description: "You want to improve software tools and infrastructure.", name: "Technology"}
  @invalid_attrs %{name: nil}

  defp request_create(conn, attrs) do
    path = conn |> category_path(:create)
    payload = json_payload(:category, attrs)
    conn |> post(path, payload)
  end

  defp request_update(conn, attrs) do
    category = insert(:category)
    payload = json_payload(:category, attrs)
    path = conn |> category_path(:update, category)

    conn |> put(path, payload)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, category_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      category = insert(:category)

      path = conn |> category_path(:show, category)
      assert conn |> get(path) |> json_response(200)
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      path = conn |> category_path(:show, -1)
      assert conn |> get(path) |> json_response(404)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(201)
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      response = conn |> request_create(@invalid_attrs) |> json_response(422)

      assert response["errors"] != %{}
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(401)
    end
  end

  describe "update" do
    @tag authenticated: :admin
    test "updates and renders chosen resource when data is valid", %{conn: conn} do
      assert conn |> request_update(@valid_attrs) |> json_response(200)
    end

    @tag authenticated: :admin
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      response = conn |> request_update(@invalid_attrs) |> json_response(422)

      assert response["errors"] != %{}
    end

    test "does not update resource and renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_update(@valid_attrs) |> json_response(401)
    end

    @tag :authenticated
    test "does not update resource and renders 401 when not authorized", %{conn: conn} do
      assert conn |> request_update(@valid_attrs) |> json_response(401)
    end
  end
end

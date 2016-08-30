defmodule CodeCorps.CategoryControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Category

  @valid_attrs %{description: "You want to improve software tools and infrastructure.", name: "Technology"}
  @invalid_attrs %{name: nil}

  defp build_payload(id, attributes, relationships \\ %{}) do
    build_payload(attributes)
    |> put_in(["data", "id"], id)
    |> put_in(["data", "relationships"], relationships)
  end

  defp build_payload(attributes) do
    %{ "data" => %{"type" => "category", "attributes" => attributes}}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, category_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      category = insert(:category)

      path = conn |> category_path(:show, category)
      data = conn |> get(path) |> json_response(200) |> Map.get("data")

      assert data["id"] == category.id |> Integer.to_string
      assert data["type"] == "category"

      assert data["attributes"]["name"] == category.name
      assert data["attributes"]["slug"] == category.slug
      assert data["attributes"]["description"] == category.description
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, category_path(conn, :show, -1)
      end
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      conn = post conn, category_path(conn, :create), build_payload(@valid_attrs)
      response = json_response(conn, 201)

      assert response["data"]["id"]
      assert response["data"]["attributes"]["slug"] == "technology"
      assert Repo.get_by(Category, @valid_attrs)
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, category_path(conn, :create), build_payload(@invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      conn = post conn, category_path(conn, :create), build_payload(@valid_attrs)
      assert json_response(conn, 401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      conn = post conn, category_path(conn, :create), build_payload(@valid_attrs)
      assert json_response(conn, 401)
    end
  end

  describe "update" do
    @tag authenticated: :admin
    test "updates and renders chosen resource when data is valid", %{conn: conn} do
      category = insert(:category)
      updated_attrs = %{@valid_attrs | description: "New Description"}
      conn = put conn, category_path(conn, :update, category), build_payload(category.id, updated_attrs)

      assert json_response(conn, 200)["data"]["id"] == "#{category.id}"
      assert Repo.get_by(Category, updated_attrs)
    end

    @tag authenticated: :admin
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      category = insert(:category)
      conn = put conn, category_path(conn, :update, category), build_payload(category.id, @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not update resource and renders 401 when not authenticated", %{conn: conn} do
      category = insert(:category)
      conn = put conn, category_path(conn, :update, category), build_payload(category.id, @invalid_attrs)
      assert json_response(conn, 401)
    end

    @tag :authenticated
    test "does not update resource and renders 401 when not authorized", %{conn: conn} do
      category = insert(:category)
      conn = put conn, category_path(conn, :update, category), build_payload(category.id, @invalid_attrs)
      assert json_response(conn, 401)
    end
  end
end

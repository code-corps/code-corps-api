defmodule CodeCorps.UserCategoryControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Repo
  alias CodeCorps.UserCategory

  @attrs %{}

  defp build_payload, do: %{ "data" => %{"type" => "user-category", "attributes" => %{}}}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      path = conn |> user_category_path(:index)
      json = conn |> get(path) |> json_response(200)

      assert json["data"] == []
    end

    test "filters resources on index", %{conn: conn} do
      society = insert(:category, name: "Society")
      technology = insert(:category, name: "Technology")
      government = insert(:category, name: "Government")

      user = insert(:user)
      user_category_1 = insert(:user_category, user: user, category: society)
      user_category_2 = insert(:user_category, user: user, category: technology)
      insert(:user_category, user: user, category: government)

      path = "user-categories/?filter[id]=#{user_category_1.id},#{user_category_2.id}"
      json = conn |> get(path) |> json_response(200)

      data = json["data"]
      assert length(data) == 2

      [first_result, second_result | _] = data
      assert first_result["id"] == "#{user_category_1.id}"
      assert second_result["id"] == "#{user_category_2.id}"
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      user_category = insert(:user_category)

      path = conn |> user_category_path(:show, user_category)
      json = conn |> get(path) |> json_response(200)

      data = json["data"]
      assert data["id"] == "#{user_category.id}"
      assert data["type"] == "user-category"
      assert data["relationships"]["user"]["data"]["id"] == "#{user_category.user_id}"
      assert data["relationships"]["category"]["data"]["id"] == "#{user_category.category_id}"
    end

    test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      path = conn |> user_category_path(:show, -1)
      assert conn |> get(path) |> json_response(:not_found)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      user = insert(:user)
      category = insert(:category)

      payload = build_payload |> put_relationships(user, category)
      path = conn |> user_category_path(:create)
      json = conn |> post(path, payload) |> json_response(201)

      id = json["data"]["id"] |> String.to_integer
      user_category = UserCategory |> Repo.get(id)

      assert json["data"]["id"] == "#{user_category.id}"
      assert json["data"]["type"] == "user-category"
      assert json["data"]["relationships"]["user"]["data"]["id"] == "#{user.id}"
      assert json["data"]["relationships"]["category"]["data"]["id"] == "#{category.id}"
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      payload = build_payload
      path = conn |> user_category_path(:create)
      json = conn |> get(path, payload) |> json_response(200)

      assert json["errors"] != %{}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> user_category_path(:create)
      assert conn |> post(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      path = conn |> user_category_path(:create)
      assert conn |> post(path, build_payload) |> json_response(401)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes resource", %{conn: conn} do
      user_category = insert(:user_category)
      path = conn |> user_category_path(:delete, user_category)
      assert conn |> delete(path) |> response(204)
    end

    test "does not delete resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> user_category_path(:delete, "id not important")
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      user_category = insert(:user_category)
      path = conn |> user_category_path(:delete, user_category)
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "renders page not found when id is nonexistent on delete", %{conn: conn} do
      path = conn |> user_category_path(:delete, -1)
      assert conn |> delete(path) |> json_response(404)
    end
  end
end

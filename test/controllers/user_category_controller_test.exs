defmodule CodeCorps.UserCategoryControllerTest do
  use CodeCorps.ApiCase, resource_name: :user_category

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [user_category_1, user_category_2] = insert_pair(:user_category)

      conn
       |> request_index
       |> json_response(200)
       |> assert_ids_from_response([user_category_1.id, user_category_2.id])
    end

    test "filters resources on index", %{conn: conn} do
      [user_category_1, user_category_2 | _] = insert_list(3, :user_category)

      path = "user-categories/?filter[id]=#{user_category_1.id},#{user_category_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([user_category_1.id, user_category_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      user_category = insert(:user_category)
      conn
      |> request_show(user_category)
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(user_category.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      user = insert(:user)
      category = insert(:category)
      attrs = (%{user: user, category: category})
      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag authenticated: :admin
    test "renders 422 when data is invalid", %{conn: conn} do
      assert conn |> request_create |> json_response(422)
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
    test "renders 404 when id is nonexistent on delete", %{conn: conn} do
      assert conn |> request_delete(:not_found) |> json_response(404)
    end
  end
end

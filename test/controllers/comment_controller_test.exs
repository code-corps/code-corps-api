defmodule CodeCorps.CommentControllerTest do
  use CodeCorps.ApiCase, resource_name: :comment

  @valid_attrs %{markdown: "I love elixir!"}
  @invalid_attrs %{markdown: ""}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      path = conn |> comment_path(:index)
      conn = conn |> get(path)

      assert json_response(conn, 200)["data"] == []
    end

    test "filters resources on index", %{conn: conn} do
      first_comment = insert(:comment)
      second_comment = insert(:comment)
      insert(:comment)

      path = "comments/?filter[id]=#{first_comment.id},#{second_comment.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([first_comment.id, second_comment.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      comment = insert(:comment)
      conn
      |> request_show(comment)
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(comment.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      task = insert(:task)
      attrs = @valid_attrs |> Map.merge(%{task: task, user: current_user})
      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag :authenticated
    test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: current_user} do
      attrs = @invalid_attrs |> Map.merge(%{user: current_user})
      json = conn |> request_create(attrs) |> json_response(422)
      assert json["errors"] != %{}
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(403)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders chosen resource when data is valid", %{conn: conn, current_user: current_user} do
      comment = insert(:comment, user: current_user)
      attrs = @valid_attrs |> Map.merge(%{user: current_user})
      assert conn |> request_update(comment, attrs) |> json_response(200)
    end

    @tag :authenticated
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: current_user} do
      comment = insert(:comment, user: current_user)
      attrs = @invalid_attrs |> Map.merge(%{user: current_user})
      json = conn |> request_update(comment, attrs) |> json_response(422)
      assert json["errors"] != %{}
    end

    test "does not update resource and renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_update(@valid_attrs) |> json_response(401)
    end

    @tag :authenticated
    test "does not update resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_update(@valid_attrs) |> json_response(403)
    end
  end
end

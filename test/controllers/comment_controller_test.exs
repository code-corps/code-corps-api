defmodule CodeCorps.CommentControllerTest do
  use CodeCorps.ApiCase

  @valid_attrs %{markdown: "I love elixir!"}
  @invalid_attrs %{markdown: ""}

  def request_create(conn, attrs) do
    path = conn |> comment_path(:create)
    payload = json_payload(:comment, attrs)
    conn |> post(path, payload)
  end

  def request_update(conn, attrs) do
    comment = insert(:comment)
    payload = json_payload(:comment, attrs)
    path = conn |> comment_path(:update, comment)

    conn |> put(path, payload)
  end

  describe "index" do
    test "lists all entries for specified task on index", %{conn: conn} do
      task = insert(:task)
      path = conn |> task_comment_path(:index, task)
      conn = conn |> get(path)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      comment = insert(:comment)

      path = conn |> comment_path(:show, comment)
      conn = conn |> get(path)

      assert json_response(conn, 200)
    end

    test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, comment_path(conn, :show, -1)
      end
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(201)
    end

    @tag :authenticated
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      response = conn |> request_create(@invalid_attrs) |> json_response(422)

      assert response["errors"] != %{}
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(401)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders chosen resource when data is valid", %{conn: conn, current_user: current_user} do
      assert conn |> request_update(@valid_attrs) |> json_response(200)
    end

    @tag :authenticated
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: current_user} do
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

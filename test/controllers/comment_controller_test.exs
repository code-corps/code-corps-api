defmodule CodeCorps.CommentControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Comment
  alias CodeCorps.Repo

  @valid_attrs %{markdown: "I love elixir!"}
  @invalid_attrs %{markdown: ""}

  defp build_payload, do: %{ "data" => %{"type" => "comment"}}

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

      data = json_response(conn, 200)["data"]

      assert data["id"] == "#{comment.id}"
      assert data["type"] == "comment"
      assert data["attributes"]["body"] == comment.body
      assert data["attributes"]["markdown"] == comment.markdown
      assert data["relationships"]["user"]["data"]["id"] == "#{comment.user_id}"
      assert data["relationships"]["task"]["data"]["id"] == "#{comment.task_id}"
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      path = conn |> comment_path(:show, -1)
      assert conn |> get(path) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)

      payload =
        build_payload
        |> put_attributes(@valid_attrs)
        |> put_relationships(current_user, task)

      path = conn |> comment_path(:create)
      conn = conn |> post(path, payload)

      assert json_response(conn, 201)["data"]["id"]
      assert Repo.get_by(Comment, @valid_attrs)
    end

    @tag :authenticated
    test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: current_user} do
      task = insert(:task, user: current_user)

      payload =
        build_payload
        |> put_attributes(@invalid_attrs)
        |> put_relationships(current_user, task)

      path = conn |> comment_path(:create)
      conn = conn |> post(path, payload)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      user = insert(:user)
      task = insert(:task, user: user)

      payload =
        build_payload
        |> put_attributes(@valid_attrs)
        |> put_relationships(user, task)

      path = conn |> comment_path(:create)
      conn = conn |> post(path, payload)

      assert json_response(conn, 401)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders chosen resource when data is valid", %{conn: conn, current_user: current_user} do
      comment = insert(:comment, user: current_user)

      payload =
        build_payload
        |> put_id(comment.id)
        |> put_attributes(@valid_attrs)

      path = conn |> comment_path(:update, comment)
      conn = conn |> put(path, payload)

      assert json_response(conn, 200)["data"]["id"]
      assert Repo.get_by(Comment, @valid_attrs)
    end

    @tag :authenticated
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: current_user} do
      comment = insert(:comment, user: current_user)

      payload =
        build_payload
        |> put_id(comment.id)
        |> put_attributes(@invalid_attrs)

      path = conn |> comment_path(:update, comment)
      conn = conn |> put(path, payload)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not update resource and renders 401 when not authenticated", %{conn: conn} do
      comment = insert(:comment)

      payload =
        build_payload
        |> put_id(comment.id)
        |> put_attributes(@valid_attrs)

      path = conn |> comment_path(:update, comment)
      conn = conn |> put(path, payload)

      assert json_response(conn, 401)
    end

    @tag :authenticated
    test "does not update resource and renders 401 when not authorized", %{conn: conn} do
      comment = insert(:comment)

      payload =
        build_payload
        |> put_id(comment.id)
        |> put_attributes(@valid_attrs)

      path = conn |> comment_path(:update, comment)
      conn = conn |> put(path, payload)

      assert json_response(conn, 401)
    end
  end
end

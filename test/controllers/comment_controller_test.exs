defmodule CodeCorps.CommentControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Comment
  alias CodeCorps.Repo

  @valid_attrs %{markdown: "I love elixir!"}
  @invalid_attrs %{markdown: ""}

  defp build_payload, do: %{ "data" => %{"type" => "comment"}}
  defp put_id(payload, id), do: payload |> put_in(["data", "id"], id)
  defp put_attributes(payload, attributes), do: payload |> put_in(["data", "attributes"], attributes)
  defp put_relationships(payload, user, post) do
    relationships = build_relationships(user, post)
    payload |> put_in(["data", "relationships"], relationships)
  end

  defp build_relationships(user, post) do
    %{
      user: %{data: %{id: user.id}},
      post: %{data: %{id: post.id}}
    }
  end

  test "lists all entries on index", %{conn: conn} do
    path = conn |> comment_path(:index)
    conn = conn |> get(path)
    assert json_response(conn, 200)["data"] == []
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
      assert data["relationships"]["post"]["data"]["id"] == "#{comment.post_id}"
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
      user = insert(:user)
      post = insert(:post, user: user)

      payload =
        build_payload
        |> put_attributes(@valid_attrs)
        |> put_relationships(user, post)

      path = conn |> comment_path(:create)
      conn = conn |> post(path, payload)

      assert json_response(conn, 201)["data"]["id"]
      assert Repo.get_by(Comment, @valid_attrs)
    end

    @tag :authenticated
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      payload = build_payload |> put_attributes(@invalid_attrs)

      path = conn |> comment_path(:create)
      conn = conn |> post(path, payload)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      user = insert(:user)
      post = insert(:post, user: user)

      payload =
        build_payload
        |> put_attributes(@valid_attrs)
        |> put_relationships(user, post)

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

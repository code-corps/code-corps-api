defmodule CodeCorps.PostControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Post
  alias CodeCorps.Repo

  @valid_attrs %{
    title: "Test post",
    post_type: "issue",
    markdown: "A test post",
    status: "open"
  }

  @invalid_attrs %{
    post_type: "nonexistent",
    status: "nonexistent"
  }

  defp build_payload, do: %{ "data" => %{"type" => "post"}}
  defp put_id(payload, id), do: payload |> put_in(["data", "id"], id)
  defp put_attributes(payload, attributes), do: payload |> put_in(["data", "attributes"], attributes)
  defp put_relationships(payload, user, project) do
    relationships = build_relationships(user, project)
    payload |> put_in(["data", "relationships"], relationships)
  end

  defp build_relationships(user, project) do
    %{
      user: %{data: %{id: user.id}},
      project: %{data: %{id: project.id}}
    }
  end

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      path = conn |> post_path(:index)
      json = conn |> get(path) |> json_response(200)
      assert json["data"] == []
    end

    test "lists all posts for a project", %{conn: conn} do
      project_1 = insert(:project)
      project_2 = insert(:project)
      user = insert(:user)
      insert(:post, project: project_1, user: user)
      insert(:post, project: project_1, user: user)
      insert(:post, project: project_2, user: user)

      json =
        conn
        |> get("projects/#{project_1.id}/posts")
        |> json_response(200)

      assert json["data"] |> Enum.count == 2
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      post = insert(:post)
      path = conn |> post_path(:show, post)

      data = conn |> get(path) |> json_response(200) |> Map.get("data")
      post = Post |> Repo.get(post.id)

      assert data["id"] == "#{post.id}"
      assert data["type"] == "post"
      assert data["attributes"]["body"] == post.body
      assert data["attributes"]["markdown"] == post.markdown
      assert data["attributes"]["number"] == post.number
      assert data["attributes"]["post-type"] == post.post_type
      assert data["attributes"]["status"] == post.status
      assert data["attributes"]["title"] == post.title
    end

    test "shows post by number for project", %{conn: conn} do
      post = insert(:post)
      post = Post |> Repo.get(post.id)

      path = conn |> project_post_path(:show, post.project_id, post.number)
      data = conn |> get(path) |> json_response(200) |> Map.get("data")

      assert data["id"] == "#{post.id}"
      assert data["type"] == "post"
    end

    test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, post_path(conn, :show, -1)
      end
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn} do
      user = insert(:user)
      project = insert(:project)

      payload =
        build_payload
        |> put_attributes(@valid_attrs)
        |> put_relationships(user, project)

      path = conn |> post_path(:create)
      json = conn |> post(path, payload) |> json_response(201)

      assert json["data"]["id"]
      assert Repo.get_by(Post, @valid_attrs)
    end

    @tag :authenticated
    test "does not create resource and renders 422 when data is invalid", %{conn: conn} do
      payload = build_payload |> put_attributes(@invalid_attrs)

      path = conn |> post_path(:create)
      json = conn |> post(path, payload) |> json_response(422)

      assert json["errors"] != %{}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      payload = build_payload |> put_attributes(@invalid_attrs)

      path = conn |> post_path(:create)
      assert conn |> post(path, payload) |> json_response(401)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates and renders chosen resource when data is valid", %{conn: conn, current_user: current_user} do
      post = insert(:post, user: current_user)

      payload =
        build_payload
        |> put_id(post.id)
        |> put_attributes(@valid_attrs)

      path = conn |> post_path(:update, post)
      json = conn |> put(path, payload) |> json_response(200)

      assert json["data"]["id"]
      assert Repo.get_by(Post, @valid_attrs)
    end

    @tag :authenticated
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: current_user} do
      post = insert(:post, user: current_user)

      payload =
        build_payload
        |> put_id(post.id)
        |> put_attributes(@invalid_attrs)

      path = conn |> post_path(:update, post)
      json = conn |> put(path, payload) |> json_response(422)

      assert json["errors"] != %{}
    end

    test "does not update resource and renders 401 when unauthenticated", %{conn: conn} do
      post = insert(:post)
      payload = build_payload |> put_id(post.id) |> put_attributes(@invalid_attrs)

      path = conn |> post_path(:update, post)
      assert conn |> put(path, payload) |> json_response(401)
    end

    @tag :authenticated
    test "does not update resource and renders 401 when not authorized", %{conn: conn} do
      post = insert(:post)
      payload = build_payload |> put_id(post.id) |> put_attributes(@invalid_attrs)

      path = conn |> post_path(:update, post)
      assert conn |> put(path, payload) |> json_response(401)
    end
  end
end

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
    test "lists all entries", %{conn: conn} do
      path = conn |> post_path(:index)
      json = conn |> get(path) |> json_response(200)
      assert json["data"] == []
    end

    test "lists all entries newest first", %{conn: conn} do
      # Has to be done manually. Inserting as a list is too quick.
      # Field lacks the resolution to differentiate.
      post_1 = insert(:post, inserted_at: Ecto.DateTime.cast!("2000-01-15T00:00:10"))
      post_2 = insert(:post, inserted_at: Ecto.DateTime.cast!("2000-01-15T00:00:20"))
      post_3 = insert(:post, inserted_at: Ecto.DateTime.cast!("2000-01-15T00:00:30"))

      path = conn |> post_path(:index)
      json = conn |> get(path) |> json_response(200)

      ids =
        json["data"]
        |> Enum.map(&Map.get(&1, "id"))
        |> Enum.map(&Integer.parse/1)
        |> Enum.map(fn({id, _rem}) -> id end)

      assert ids == [post_3.id, post_2.id, post_1.id]
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

    test "lists all posts filtered by post_type", %{conn: conn} do
      project_1 = insert(:project)
      user = insert(:user)
      insert(:post, post_type: "idea", project: project_1, user: user)
      insert(:post, post_type: "issue", project: project_1, user: user)
      insert(:post, post_type: "task", project: project_1, user: user)

      json =
        conn
        |> get("projects/#{project_1.id}/posts?post_type=idea,issue")
        |> json_response(200)

      assert json["data"] |> Enum.count == 2

      post_types =
        json["data"]
        |> Enum.map(fn(post_json) -> post_json["attributes"] end)
        |> Enum.map(fn(post_attributes) -> post_attributes["post-type"] end)

      assert post_types |> Enum.member?("issue")
      assert post_types |> Enum.member?("idea")
      refute post_types |> Enum.member?("task")
    end

    test "lists all posts filtered by status", %{conn: conn} do
      project = insert(:project)
      post_1 = insert(:post, status: "open", project: project)
      post_2 = insert(:post, status: "closed", project: project)

      json =
        conn
        |> get("projects/#{project.id}/posts?status=open")
        |> json_response(200)

      assert json["data"] |> Enum.count == 1
      [post] = json["data"]
      assert post["id"] == post_1.id |> Integer.to_string

      json =
        conn
        |> get("projects/#{project.id}/posts?status=closed")
        |> json_response(200)

      assert json["data"] |> Enum.count == 1
      [post] = json["data"]
      assert post["id"] == post_2.id |> Integer.to_string
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

      # ensure record is reloaded from database before serialized, since number is added
      # on database level upon insert
      assert json["data"]["attributes"]["number"] == 1
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

  describe "pagination" do
    test "specifying a page size works", %{conn: conn} do
      project_1 = insert(:project)
      user = insert(:user)
      insert(:post, project: project_1, user: user)
      insert(:post, project: project_1, user: user)
      insert(:post, project: project_1, user: user)

      path = conn |> post_path(:index)
      json =
        conn
        |> get(path, page: %{page_size: 2})
        |> json_response(200)

      assert json["data"] |> Enum.count == 2
    end

    test "specifying a page number works", %{conn: conn} do
      project_1 = insert(:project)
      user = insert(:user)
      insert(:post, project: project_1, user: user)
      insert(:post, project: project_1, user: user)
      post_to_test = insert(:post, project: project_1, user: user)
      insert(:post, project: project_1, user: user)

      path = conn |> post_path(:index)
      json =
        conn
        |> get(path, page: %{ page: 2, page_size: 2 })
        |> json_response(200)

      [ %{"id" => id} | _ ] = json["data"]

      assert String.to_integer(id) == post_to_test.id
    end

    test "paginated results include a valid meta key", %{conn: conn} do
      project_1 = insert(:project)
      user = insert(:user)
      insert(:post, project: project_1, user: user)
      insert(:post, project: project_1, user: user)
      insert(:post, project: project_1, user: user)
      insert(:post, project: project_1, user: user)
      insert(:post, project: project_1, user: user)
      insert(:post, project: project_1, user: user)

      meta = %{
        "total_records" => 6,
        "total_pages" => 3,
        "page_size" => 2,
        "current_page" => 1,
      }
      path = conn |> post_path(:index)
      json =
        conn
        |> get(path, page: %{ page_size: 2 })
        |> json_response(200)

      assert json["meta"] == meta
    end
  end
end

defmodule CodeCorps.PostControllerTest do
  use CodeCorps.ConnCase

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

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp relationships(user, project) do
    %{
      user: %{data: %{id: user.id}},
      project: %{data: %{id: project.id}}
    }
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, post_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
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

  test "shows chosen resource", %{conn: conn} do
    user = insert(:user)
    project = insert(:project)
    post = insert(:post, project: project, user: user)
    conn = get conn, post_path(conn, :show, post)
    post = Repo.get(Post, post.id)
    data = json_response(conn, 200)["data"]
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
    user = insert(:user)
    project = insert(:project)
    post = insert(:post, project: project, user: user)
    post = Repo.get(Post, post.id)
    conn = get conn, project_post_path(conn, :show, project.id, post.number)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{post.id}"
    assert data["type"] == "post"
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    user = insert(:user)
    project = insert(:project)
    conn = post conn, post_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "post",
        "attributes" => @valid_attrs,
        "relationships" => relationships(user, project)
      }
    }

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "post",
        "attributes" => @invalid_attrs,
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = insert(:user)
    project = insert(:project)
    post = insert(:post, project: project, user: user)
    conn = put conn, post_path(conn, :update, post), %{
      "meta" => %{},
      "data" => %{
        "type" => "post",
        "id" => post.id,
        "attributes" => @valid_attrs,
      }
    }

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = insert(:user)
    project = insert(:project)
    post = insert(:post, project: project, user: user)
    conn = put conn, post_path(conn, :update, post), %{
      "meta" => %{},
      "data" => %{
        "type" => "post",
        "id" => post.id,
        "attributes" => @invalid_attrs,
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end
end

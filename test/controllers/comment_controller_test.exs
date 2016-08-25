defmodule CodeCorps.CommentControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Comment
  alias CodeCorps.Repo

  @valid_attrs %{markdown: "I love elixir!"}
  @invalid_attrs %{markdown: ""}

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp relationships(user, post) do
    %{
      user: %{data: %{id: user.id}},
      post: %{data: %{id: post.id}}
    }
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, comment_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    user = insert(:user)
    project = insert(:project)
    post = insert(:post, project: project, user: user)
    comment = insert(:comment, post: post, user: user)
    conn = get conn, comment_path(conn, :show, comment)
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

  test "creates and renders resource when data is valid", %{conn: conn} do
    user = insert(:user)
    project = insert(:project)
    post = insert(:post, project: project, user: user)
    conn = post conn, comment_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "comment",
        "attributes" => @valid_attrs,
        "relationships" => relationships(user, post)
      }
    }

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Comment, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, comment_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "comment",
        "attributes" => @invalid_attrs,
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = insert(:user)
    project = insert(:project)
    post = insert(:post, project: project, user: user)
    comment = insert(:comment, post: post, user: user)
    conn = put conn, comment_path(conn, :update, comment), %{
      "meta" => %{},
      "data" => %{
        "type" => "comment",
        "id" => comment.id,
        "attributes" => @valid_attrs,
      }
    }

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Comment, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = insert(:user)
    project = insert(:project)
    post = insert(:post, project: project, user: user)
    comment = insert(:comment, post: post, user: user)
    conn = put conn, comment_path(conn, :update, comment), %{
      "meta" => %{},
      "data" => %{
        "type" => "comment",
        "id" => comment.id,
        "attributes" => @invalid_attrs,
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end
end

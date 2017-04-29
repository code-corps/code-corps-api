defmodule CodeCorps.GithubIssueControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Task
  @valid_attrs %{
    "issue": {
      "id": 73464126,
      "title": "Spelling error in the README file",
      "user": {
        "login": "baxterthehacker",
        "id": 6752317
      },
      "labels": [
        {
          "id": 208045946,
          "url": "https://api.github.com/repos/baxterthehacker/public-repo/labels/bug",
          "name": "bug",
          "color": "fc2929",
          "default": true
        }
      ],
      "body": "It looks like you accidently spelled 'commit' with two 't's."
    },
    "repository": {
      "id": 35129377,
      "name": "public-repo",
      "full_name": "baxterthehacker/public-repo",
      "owner": {
        "login": "baxterthehacker",
        "id": 6752317
      },
    }
  }
  @invalid_attrs %{
    "action": "foo"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "handles create", %{conn: conn} do
    create_attr = @valid_attrs ++ %{"action" => "opened"}
    post conn, github_issue_path(conn, :handle), create_attr
    assert json_response(conn, 200)
    assert Repo.get_by(Task, github_id: 73464126)
  end

  test "handles edit", %{conn: conn} do
    task = insert(:task, github_id: 73464126, title: "foo")
    edit_attr = @valid_attrs ++ %{"action" => "edited"}
    conn = post conn, github_issue_path(conn, :handle), edit_attr
    assert json_response(conn, 200)
    assert task.title == @valid_attrs["issue"]["title"]
  end

  test "handles destroy", %{conn: conn} do
    task = insert(:task, github_id: 73464126)
    delete_attr = @valid_attrs ++ %{"action" => "deleted"}
    conn = post conn, github_issue_path(conn, :handle), delete_attr
    assert json_response(conn, 200)
    refute Repo.get_by(Task, github_id: 73464126)
  end
end

defmodule CodeCorps.GithubIssueControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Task
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, github_issue_path(conn, :create), github_issue: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(GithubIssue, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, github_issue_path(conn, :create), github_issue: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end
end

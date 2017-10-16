defmodule CodeCorps.GithubIssueTest do
  use CodeCorps.ModelCase

  alias CodeCorps.GithubIssue

  @valid_attrs %{
    body: "I'm having a problem with this.",
    closed_at: nil,
    comments_url: "https://api.github.com/repos/octocat/Hello-World/issues/1347/comments",
    events_url: "https://api.github.com/repos/octocat/Hello-World/issues/1347/events",
    github_created_at: "2011-04-22T13:33:48Z",
    github_id: 1,
    github_updated_at: "2014-03-03T18:58:10Z",
    html_url: "https://github.com/octocat/Hello-World/issues/1347",
    labels_url: "https://api.github.com/repos/octocat/Hello-World/issues/1347/labels{/name}",
    locked: false,
    number: 1347,
    repository_url: "https://api.github.com/repos/octocat/Hello-World",
    state: "open",
    title: "Found a bug",
    url: "https://api.github.com/repos/octocat/Hello-World/issues/1347",
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GithubIssue.changeset(%GithubIssue{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with missing body" do
    attrs = @valid_attrs |> Map.delete(:body)
    changeset = GithubIssue.changeset(%GithubIssue{}, attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GithubIssue.changeset(%GithubIssue{}, @invalid_attrs)
    refute changeset.valid?
  end
end

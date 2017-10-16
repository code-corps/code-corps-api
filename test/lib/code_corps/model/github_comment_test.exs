defmodule CodeCorps.GithubCommentTest do
  use CodeCorps.ModelCase

  alias CodeCorps.GithubComment

  @valid_attrs %{
    body: "I'm having a problem with this.",
    github_created_at: "2011-04-22T13:33:48Z",
    github_id: 1,
    github_updated_at: "2014-03-03T18:58:10Z",
    html_url: "https://github.com/octocat/Hello-World/issues/1347",
    url: "https://api.github.com/repos/octocat/Hello-World/issues/1347",
  }
  @invalid_attrs %{}

  test "create_changeset/2 with valid attributes" do
    changeset = GithubComment.create_changeset(%GithubComment{}, @valid_attrs)
    assert changeset.valid?
  end

  test "create_changeset/2 with invalid attributes" do
    changeset = GithubComment.create_changeset(%GithubComment{}, @invalid_attrs)
    refute changeset.valid?
  end
end

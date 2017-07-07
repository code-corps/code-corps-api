defmodule CodeCorps.GithubRepoTest do
  use CodeCorps.ModelCase

  alias CodeCorps.GithubRepo

  test "deletes associated ProjectGithubRepo records when deleting GithubRepo" do
    github_repo = insert(:github_repo)
    insert_pair(:project_github_repo, github_repo: github_repo)

    github_repo |> Repo.delete

    assert Repo.aggregate(GithubRepo, :count, :id) == 0
  end
end

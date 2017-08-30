defmodule CodeCorps.GitHub.Event.Common.RepoFinderTest do
  use CodeCorps.DbAccessCase

  import CodeCorps.{Factories, TestHelpers.GitHub}

  alias CodeCorps.GitHub.Event.Common.RepoFinder

  @loadable_event_fixtures ~w(issue_comment_created issue_comment_edited issue_comment_deleted issues_closed issues_opened issues_edited issues_reopened)

  describe "find_repo/1" do
    @loadable_event_fixtures |> Enum.each(fn fixture ->
      @fixture fixture

      setup do
        {:ok, %{payload: load_event_fixture(@fixture)}}
      end

      test "loads properly for event fixture #{@fixture}", %{payload: payload} do
        # if no repo locally, returns error
        assert RepoFinder.find_repo(payload) == {:error, :unmatched_repository}

        # if repo is found but is not connected to any projects, returns error
        github_repo = insert(:github_repo, github_id: payload["repository"]["id"])
        assert RepoFinder.find_repo(payload) == {:error, :unmatched_project}

        # returns repo if all is in order
        %{id: project_github_repo_id} = insert(:project_github_repo, github_repo: github_repo)
        {:ok, %{id: found_repo_id, project_github_repos: project_github_repos}} = RepoFinder.find_repo(payload)
        assert found_repo_id == github_repo.id
        assert Enum.map(project_github_repos, &Map.get(&1, :id)) == [project_github_repo_id]
      end
    end)
  end
end

defmodule CodeCorps.GitHub.Event.Common.RepoFinderTest do
  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GitHub.Event.Common.RepoFinder

  @loadable_event_fixtures ~w(issue_comment_created issue_comment_edited issue_comment_deleted issues_closed issues_opened issues_edited issues_reopened)

  @loadable_event_fixtures |> Enum.each(fn fixture ->
    @fixture fixture

    setup do
      {:ok, %{payload: load_event_fixture(@fixture)}}
    end

    describe "finder_repo for #{@fixture}" do
      test "returns error if no matched repository", %{payload: payload} do
        assert RepoFinder.find_repo(payload) == {:error, :unmatched_repository}
      end

      test "returns repository if matched, preloads project github repos", %{payload: payload} do
        github_repo = insert(:github_repo, github_id: payload["repository"]["id"])
        {:ok, %{id: found_repo_id}} = RepoFinder.find_repo(payload)
        assert found_repo_id == github_repo.id
      end
    end
  end)
end

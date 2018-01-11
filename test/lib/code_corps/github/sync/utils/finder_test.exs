defmodule CodeCorps.GitHub.Sync.Utils.FinderTest do
  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GitHub.Sync.Utils.Finder

  @supported_repo_fixtures ~w(issue_comment_created issue_comment_edited issue_comment_deleted issues_closed issues_opened issues_edited issues_reopened)

  @supported_repo_fixtures |> Enum.each(fn repo_fixture ->
    @repo_fixture repo_fixture

    describe "find_repo for #{@repo_fixture}" do
      test "returns error if no matched repository" do
        payload = load_event_fixture(@repo_fixture)
        assert Finder.find_repo(payload) == {:error, :unmatched_repository}
      end

      test "returns repository if matched, preloads github repos" do
        payload = load_event_fixture(@repo_fixture)
        github_repo = insert(:github_repo, github_id: payload["repository"]["id"])
        {:ok, %{id: found_repo_id}} = Finder.find_repo(payload)
        assert found_repo_id == github_repo.id
      end
    end
  end)

  @supported_installation_fixtures ~w(installation_repositories_added installation_repositories_removed)

  @supported_installation_fixtures |> Enum.each(fn installation_fixture ->
    @installation_fixture installation_fixture

    setup do
      {:ok, %{payload: load_event_fixture(@installation_fixture)}}
    end

    describe "find_installation for #{@installation_fixture}" do
      test "returns error if no matched repository" do
        payload = load_event_fixture(@installation_fixture)
        assert Finder.find_installation(payload) == {:error, :unmatched_installation}
      end

      test "returns repository if matched, preloads github repos" do
        payload = load_event_fixture(@installation_fixture)
        installation = insert(:github_app_installation, github_id: payload["installation"]["id"])
        {:ok, %{id: installation_id}} = Finder.find_installation(payload)
        assert installation_id == installation.id
      end
    end
  end)
end

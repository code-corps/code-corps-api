defmodule CodeCorps.GitHub.Sync.Issue.GithubIssueTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GithubIssue,
    Repo
  }
  alias CodeCorps.GitHub.Sync.Issue.GithubIssue, as: GithubIssueSyncer
  alias CodeCorps.GitHub.Adapters.Issue, as: IssueAdapter

  @payload load_event_fixture("issues_opened")

  describe "create_or_update_issue/1" do
    test "creates issue if none exists" do
      %{"issue" => attrs} = @payload
      github_repo = insert(:github_repo)
      {:ok, %GithubIssue{} = created_issue} = GithubIssueSyncer.create_or_update_issue(github_repo, attrs)

      assert Repo.one(GithubIssue)

      created_attributes =
        attrs
        |> IssueAdapter.to_issue
        |> Map.delete(:closed_at)
        |> Map.delete(:repository_url)
      returned_issue = Repo.get_by(GithubIssue, created_attributes)
      assert returned_issue.id == created_issue.id
      assert returned_issue.github_repo_id == github_repo.id
    end

    test "updates issue if it already exists" do
      %{"issue" => %{"id" => issue_id} = attrs} = @payload

      github_repo = insert(:github_repo)
      issue = insert(:github_issue, github_id: issue_id, github_repo: github_repo)

      {:ok, %GithubIssue{} = updated_issue} = GithubIssueSyncer.create_or_update_issue(github_repo, attrs)

      assert updated_issue.id == issue.id
      assert updated_issue.github_repo_id == github_repo.id
    end

    test "returns changeset if payload is somehow not as expected" do
      bad_payload = @payload |> put_in(["issue", "number"], nil)
      %{"issue" => attrs} = bad_payload
      github_repo = insert(:github_repo)

      {:error, changeset} = GithubIssueSyncer.create_or_update_issue(github_repo, attrs)
      refute changeset.valid?
    end
  end
end

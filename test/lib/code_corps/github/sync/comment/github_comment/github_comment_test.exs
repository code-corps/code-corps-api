defmodule CodeCorps.GitHub.Sync.Comment.GithubCommentTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Adapters,
    GithubComment,
    Repo
  }
  alias CodeCorps.GitHub.Sync.Comment.GithubComment, as: GithubCommentSyncer

  @payload load_event_fixture("issue_comment_created")

  describe "create_or_update_comment/1" do
    test "creates comment if none exists" do
      %{"comment" => attrs} = @payload
      github_issue = insert(:github_issue)
      {:ok, %GithubComment{} = created_comment} = GithubCommentSyncer.create_or_update_comment(github_issue, attrs)

      assert Repo.one(GithubComment)

      created_attributes = attrs |> Adapters.Comment.to_github_comment
      returned_comment = Repo.get_by(GithubComment, created_attributes)
      assert returned_comment.id == created_comment.id
      assert returned_comment.github_issue_id == github_issue.id
    end

    test "updates issue if it already exists" do
      %{"comment" => %{"id" => comment_id} = attrs} = @payload

      github_issue = insert(:github_issue)
      github_comment = insert(:github_comment, github_id: comment_id, github_issue: github_issue)

      {:ok, %GithubComment{} = updated_comment} = GithubCommentSyncer.create_or_update_comment(github_issue, attrs)

      assert updated_comment.id == github_comment.id
      assert updated_comment.github_issue_id == github_issue.id
    end

    test "returns changeset if payload is somehow not as expected" do
      bad_payload = @payload |> put_in(["comment", "body"], nil)
      %{"comment" => attrs} = bad_payload
      github_issue = insert(:github_issue)

      {:error, changeset} = GithubCommentSyncer.create_or_update_comment(github_issue, attrs)
      refute changeset.valid?
    end
  end
end

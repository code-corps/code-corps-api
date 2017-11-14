defmodule CodeCorps.GitHub.Sync.CommentTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    Comment,
    GitHub.Sync,
    GithubComment,
    Repo,
    User
  }
  describe "sync/2" do
    @payload load_event_fixture("issue_comment_created")

    test "with unmatched both users, creates users, missing comments, for all projects connected with the github repo" do
      %{
        "issue" => %{
          "id" => issue_github_id,
          "user" => %{"id" => issue_user_github_id}
        },
        "comment" => %{
          "body" => comment_markdown, "id" => comment_github_id,
          "user" => %{"id" => comment_user_github_id}
        } = comment,
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: issue_user_github_id)
      github_issue = insert(:github_issue, github_id: issue_github_id)
      github_repo = insert(:github_repo, github_id: repo_github_id)
      task = insert(:task, github_issue: github_issue, github_repo: github_repo, user: user)

      changes = %{repo: github_repo, github_issue: github_issue, task: task}
      {:ok, %{comment: comment}} = Sync.Comment.sync(changes, comment) |> Repo.transaction

      comment_user = Repo.get_by(User, github_id: comment_user_github_id)

      assert comment.body
      assert comment.markdown == comment_markdown
      assert comment.user_id == comment_user.id

      Repo.all(GithubComment) |> Enum.each(fn github_comment ->
        assert github_comment.github_id == comment_github_id
        assert github_comment.body == comment_markdown
      end)

      assert Repo.aggregate(GithubComment, :count, :id) == 1
    end
  end

  describe "delete/2" do
    @payload load_event_fixture("issue_comment_deleted")

    test "deletes github comment with id specified in payload, and associated comment" do
      %{"comment" => %{"id" => github_id} = comment_payload} = @payload
      github_comment = insert(:github_comment, github_id: github_id)
      comment = insert(:comment, github_comment: github_comment)

      {:ok, %{deleted_comments: [deleted_comment], deleted_github_comment: deleted_github_comment}} =
        comment_payload
        |> Sync.Comment.delete
        |> Repo.transaction

      assert deleted_comment.id == comment.id
      assert deleted_github_comment.id == github_comment.id
      assert Repo.aggregate(Comment, :count, :id) == 0
      assert Repo.aggregate(GithubComment, :count, :id) == 0
    end
  end
end

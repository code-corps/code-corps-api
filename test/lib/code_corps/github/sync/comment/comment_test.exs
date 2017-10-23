defmodule CodeCorps.GitHub.Sync.CommentTest do
  @moduledoc false

  use CodeCorps.BackgroundProcessingCase
  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    Comment,
    GitHub,
    GithubComment,
    Task,
    Repo,
    User
  }
  alias GitHub.Sync.Comment, as: CommentSyncer

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
      tasks = insert_list(3, :task, github_issue: github_issue, github_repo: github_repo, user: user)

      changes = %{repo: github_repo, github_issue: github_issue, tasks: tasks}
      {:ok, %{comments: comments}} = CommentSyncer.sync(changes, comment) |> Repo.transaction

      assert Enum.count(comments) == 3
      assert Repo.aggregate(Task, :count, :id) == 3
      assert Repo.aggregate(Comment, :count, :id) == 3

      issue_user = Repo.get_by(User, github_id: issue_user_github_id)

      Repo.all(Task) |> Enum.each(fn task ->
        assert task.user_id == issue_user.id
        assert task.github_repo_id == github_repo.id
      end)

      comment_user = Repo.get_by(User, github_id: comment_user_github_id)

      comments |> Enum.each(fn comment ->
        assert comment.body
        assert comment.markdown == comment_markdown
        assert comment.user_id == comment_user.id
      end)

      Repo.all(GithubComment) |> Enum.each(fn github_comment ->
        assert github_comment.github_id == comment_github_id
        assert github_comment.body == comment_markdown
      end)

      assert Repo.aggregate(GithubComment, :count, :id) == 1
    end
  end

  describe "delete/2" do
    @payload load_event_fixture("issue_comment_deleted")

    test "deletes all comments with github_id specified in the payload" do
      %{"comment" => %{"id" => github_id} = comment} = @payload
      github_comment_1 = insert(:github_comment, github_id: github_id)
      github_comment_2 = insert(:github_comment)

      insert_list(3, :comment, github_comment: github_comment_1)
      insert_list(2, :comment)
      insert_list(4, :comment, github_comment: github_comment_2)

      changes = %{}

      {:ok, %{deleted_comments: deleted_comments, deleted_github_comment: deleted_github_comment}} =
        changes
        |> CommentSyncer.delete(comment)
        |> Repo.transaction

      assert Enum.count(deleted_comments) == 3
      assert deleted_github_comment.id == github_comment_1.id
      assert Repo.aggregate(Comment, :count, :id) == 6
      assert Repo.aggregate(GithubComment, :count, :id) == 1
    end
  end
end

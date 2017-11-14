defmodule CodeCorps.GitHub.Sync.Comment.CommentTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.{Comment, GithubComment, GitHub.Sync, Repo}

  describe "sync/4" do
    test "creates missing comments for each project associated with the github repo" do
      user = insert(:user)
      github_repo = insert(:github_repo)
      github_issue = insert(:github_issue, github_repo: github_repo)
      github_comment = insert(:github_comment, github_issue: github_issue)

      project = insert(:project)
      insert(:project_github_repo, github_repo: github_repo, project: project)

      task = insert(:task, project: project, user: user, github_issue: github_issue, github_repo: github_repo)

      # update will fail unless source is newer than target
      github_comment =
        github_comment
        |> Map.update!(:github_updated_at, &Timex.shift(&1, minutes: 1))

      {:ok, comment} =
        task |> Sync.Comment.Comment.sync(github_comment, user)

      assert comment.user_id == user.id
      assert comment.markdown == github_comment.body
      assert comment.github_comment_id == github_comment.id
      assert comment.task_id == task.id

      assert Repo.one(Comment)
    end

    test "updates existing comments for each project associated with the github repo" do
      user = insert(:user)
      github_repo = insert(:github_repo)
      github_issue = insert(:github_issue, github_repo: github_repo)
      github_comment = insert(:github_comment, github_issue: github_issue)

      project = insert(:project)
      insert(:project_github_repo, github_repo: github_repo, project: project)

      task = insert(:task, project: project, user: user, github_issue: github_issue, github_repo: github_repo)
      existing_comment = insert(:comment, task: task, user: user, github_comment: github_comment)

      # update will fail unless source is newer than target
      github_comment =
        github_comment
        |> Map.update!(:github_updated_at, &Timex.shift(&1, minutes: 1))

      {:ok, comment} =
        task |> Sync.Comment.Comment.sync(github_comment, user)

      assert comment.user_id == user.id
      assert comment.markdown == github_comment.body
      assert comment.github_comment_id == github_comment.id
      assert comment.task_id == task.id
      assert comment.id == existing_comment.id
    end

    test "fails on validation errors" do
      user = insert(:user)
      github_repo = insert(:github_repo)
      github_issue = insert(:github_issue, github_repo: github_repo)
      # body will trigger validation error
      github_comment = insert(:github_comment, github_issue: github_issue, body: nil)

      project = insert(:project)
      insert(:project_github_repo, github_repo: github_repo, project: project)

      task = insert(:task, project: project, user: user, github_issue: github_issue, github_repo: github_repo)

      # update will fail either way unless source is newer than target
      # we do not want to test for that problem in this test
      github_comment =
        github_comment
        |> Map.update!(:github_updated_at, &Timex.shift(&1, minutes: 1))

      %{user: user} = insert(:comment, task: task, github_comment: github_comment)

      {:error, changeset} =
        task |> Sync.Comment.Comment.sync(github_comment, user)

      refute changeset.valid?
    end
  end

  describe "delete/1" do
    test "deletes the Comment record for a GithubComment" do
      github_comment = insert(:github_comment)
      comments = insert_list(2, :comment, github_comment: github_comment)
      insert(:comment)

      comment_ids = Enum.map(comments, &Map.get(&1, :id))

      {:ok, deleted_comments} =
        github_comment.github_id
        |> Sync.Comment.Comment.delete

      assert Enum.count(deleted_comments) == 2
      assert Repo.aggregate(Comment, :count, :id) == 1
      assert Repo.aggregate(GithubComment, :count, :id) == 1

      for deleted_comment <- deleted_comments do
        assert deleted_comment.id in comment_ids
      end
    end

    test "works when there is no associated Comment record" do
      github_comment = insert(:github_comment)

      {:ok, deleted_comments} =
        github_comment.github_id
        |> Sync.Comment.Comment.delete

      assert Enum.count(deleted_comments) == 0
    end
  end
end

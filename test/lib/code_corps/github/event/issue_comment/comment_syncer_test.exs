defmodule CodeCorps.GitHub.Event.IssueComment.CommentSyncerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.IssueComment.CommentSyncer,
    Repo,
    Comment
  }

  describe "sync all/3" do
    @payload load_event_fixture("issue_comment_created")

    test "creates missing, updates existing comments for each project associated with the github repo" do
      %{
        "issue" => %{"number" => number},
        "comment" => %{"id" => comment_github_id, "body" => comment_body}
      } = @payload

      user = insert(:user)
      %{github_repo: github_repo} =
        github_issue = insert(:github_issue, number: number)

      github_comment = insert(:github_comment, github_issue: github_issue, github_id: comment_github_id)

      [%{project: project_1}, %{project: project_2}, %{project: project_3}]
        = insert_list(3, :project_github_repo, github_repo: github_repo)

      task_1 = insert(:task, project: project_1, user: user, github_issue: github_issue, github_repo: github_repo)
      task_2 = insert(:task, project: project_2, user: user, github_issue: github_issue, github_repo: github_repo)
      task_3 = insert(:task, project: project_3, user: user, github_issue: github_issue, github_repo: github_repo)

      comment_1 = insert(:comment, task: task_1, user: user, github_comment: github_comment)

      {:ok, comments} = [task_1, task_2, task_3] |> CommentSyncer.sync_all(github_comment, user, @payload)

      assert Enum.count(comments) == 3
      assert Repo.aggregate(Comment, :count, :id) == 3

      task_ids = [task_1, task_2, task_3] |> Enum.map(&Map.get(&1, :id))

      comments |> Enum.each(fn comment ->
        assert comment.user_id == user.id
        assert comment.markdown == comment_body
        assert comment.github_comment_id == github_comment.id
        assert comment.task_id in task_ids
      end)

      comment_ids = comments |> Enum.map(&Map.get(&1, :id))
      assert comment_1.id in comment_ids
    end

    test "fails on validation errors" do
      bad_payload = @payload |> put_in(~w(comment body), nil)

      %{
        "issue" => %{"number" => number},
        "comment" => %{"id" => comment_github_id}
      } = bad_payload

      %{project: project, github_repo: github_repo} =
        insert(:project_github_repo)

      github_issue = insert(:github_issue, number: number, github_repo: github_repo)
      github_comment = insert(:github_comment, github_id: comment_github_id, github_issue: github_issue)
      task = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo)

      %{user: user} = insert(:comment, task: task, github_comment: github_comment)

      {:error, {comments, errors}} =
        [task] |> CommentSyncer.sync_all(github_comment, user, bad_payload)

      assert Enum.count(comments) == 0
      assert Enum.count(errors) == 1
    end
  end
end

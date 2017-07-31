defmodule CodeCorps.GitHub.Event.IssueComment.CommentSyncerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.{Factories, TestHelpers.GitHub}

  alias CodeCorps.{
    GitHub.Event.IssueComment.CommentSyncer,
    Repo,
    Comment
  }

  describe "sync all/3" do
    @payload load_event_fixture("issue_comment_created")

    test "creates missing, updates existing comments for each project associated with the github repo" do
      user = insert(:user)
      github_repo = insert(:github_repo)

      %{
        "issue" => %{"id" => issue_github_id},
        "comment" => %{"id" => comment_github_id, "body" => comment_body}
      } = @payload

      [%{project: project_1}, %{project: project_2}, %{project: project_3}]
        = insert_list(3, :project_github_repo, github_repo: github_repo)

      task_1 = insert(:task, project: project_1, user: user, github_id: issue_github_id)
      task_2 = insert(:task, project: project_2, user: user, github_id: issue_github_id)
      task_3 = insert(:task, project: project_3, user: user, github_id: issue_github_id)

      comment_1 = insert(:comment, task: task_1, user: user, github_id: comment_github_id)

      {:ok, comments} = [task_1, task_2, task_3] |> CommentSyncer.sync_all(user, @payload)

      assert Enum.count(comments) == 3
      assert Repo.aggregate(Comment, :count, :id) == 3

      task_ids = [task_1, task_2, task_3] |> Enum.map(&Map.get(&1, :id))

      comments |> Enum.each(fn comment ->
        assert comment.user_id == user.id
        assert comment.markdown == comment_body
        assert comment.github_id == comment_github_id
        assert comment.task_id in task_ids
      end)

      comment_ids = comments |> Enum.map(&Map.get(&1, :id))
      assert comment_1.id in comment_ids
    end
  end
end

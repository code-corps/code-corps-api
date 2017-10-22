defmodule CodeCorps.GitHub.SyncTest do
  @moduledoc false

  use CodeCorps.BackgroundProcessingCase
  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    Comment,
    GitHub.Sync,
    GithubComment,
    GithubIssue,
    GithubPullRequest,
    Repo,
    Task,
    User
  }

  describe "issue_comment_event/1" do
    @payload load_event_fixture("issue_comment_created_on_pull_request")

    test "syncs the pull request, issue, comment, and user" do
      %{
        "issue" => %{
          "body" => issue_body,
          "id" => issue_github_id,
          "number" => issue_number,
          "user" => %{
            "id" => issue_user_github_id
          }
        },
        "comment" => %{
          "body" => comment_body,
          "id" => comment_github_id,
          "user" => %{
            "id" => comment_user_github_id
          }
        },
        "repository" => %{
          "id" => repo_github_id
        }
      } = @payload

      github_repo = insert(:github_repo, github_id: repo_github_id)
      %{project: project} = insert(:project_github_repo, github_repo: github_repo)
      insert(:task_list, project: project, inbox: true)

      {:ok, [comment]} = Sync.issue_comment_event(@payload)

      assert Repo.aggregate(GithubComment, :count, :id) == 1
      assert Repo.aggregate(GithubIssue, :count, :id) == 1
      assert Repo.aggregate(GithubPullRequest, :count, :id) == 1
      assert Repo.aggregate(Comment, :count, :id) == 1
      assert Repo.aggregate(Task, :count, :id) == 1

      issue_user = Repo.get_by(User, github_id: issue_user_github_id)
      assert issue_user

      comment_user = Repo.get_by(User, github_id: comment_user_github_id)
      assert comment_user

      comment = comment |> Repo.preload([:user, [task: :user], [github_comment: [github_issue: [:github_pull_request, :github_repo]]]])

      github_comment = comment.github_comment
      github_issue = github_comment.github_issue
      github_pull_request = github_issue.github_pull_request
      task = comment.task

      # Attributes
      assert comment.markdown == comment_body

      # Relationships (and their attributes)
      assert github_comment.github_id == comment_github_id
      assert github_issue.github_id == issue_github_id
      assert github_issue.body == issue_body
      assert github_issue.number == issue_number
      assert github_pull_request.number == issue_number
      assert github_pull_request.github_repo_id == github_repo.id
      assert task.markdown == issue_body
      assert task.project_id == project.id
      assert task.user.github_id == issue_user_github_id
      assert task.user_id == issue_user.id
      assert comment.markdown == comment_body
      assert comment.user_id == comment_user.id
      assert comment.user.github_id == comment_user_github_id
    end
  end
end

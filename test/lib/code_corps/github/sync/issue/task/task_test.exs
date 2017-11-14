defmodule CodeCorps.GitHub.Sync.Issue.TaskTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.{Repo, Task}
  alias CodeCorps.GitHub.Sync.Issue.Task, as: IssueTaskSyncer

  describe "sync all/3" do
    defp setup_test_data do
      # Creates a user, 3 projects and a github issue all linked to a
      # github repo. Returns that data as a map
      user = insert(:user)
      project = insert(:project)
      github_repo = insert(:github_repo)
      github_issue = insert(
        :github_issue,
        github_repo: github_repo,
        github_updated_at: DateTime.utc_now |> Timex.shift(hours: 1)
      )

      insert(:task_list, project: project, inbox: true)
      insert(:project_github_repo, project: project, github_repo: github_repo)

      %{github_issue: github_issue, github_repo: github_repo, project: project, user: user}
    end

    test "creates missing, updates existing tasks for each project associated with the github repo" do
      %{
        github_issue: github_issue,
        github_repo: github_repo,
        project: project,
        user: user
      } = setup_test_data()

      existing_task =
        insert(:task, project: project, github_issue: github_issue, github_repo: github_repo, user: user)

      {:ok, task} = github_issue |> IssueTaskSyncer.sync_github_issue(user)

      assert Repo.aggregate(Task, :count, :id) == 1

      assert task.user_id == user.id
      assert task.markdown == github_issue.body
      assert task.github_issue_id == github_issue.id

      assert existing_task.id == task.id
    end

    test "sets task :modified_from to 'github'" do
      %{github_issue: github_issue, user: user} = setup_test_data()
      {:ok, task} = github_issue |> IssueTaskSyncer.sync_github_issue(user)
      assert task.modified_from == "github"
    end

    test "fails on validation errors" do
      %{github_repo: github_repo} = github_issue = insert(:github_issue, title: nil)

      %{project: project} =
        insert(:project_github_repo, github_repo: github_repo)

      %{user: user} = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo)

      insert(:task_list, project: project, inbox: true)

      {:error, changeset} = github_issue |> IssueTaskSyncer.sync_github_issue(user)

      refute changeset.valid?
    end
  end
end

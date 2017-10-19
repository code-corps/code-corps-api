defmodule CodeCorps.GitHub.Sync.Issue.TaskTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    Project,
    Repo,
    Task
  }
  alias CodeCorps.GitHub.Sync.Issue.Task, as: IssueTaskSyncer

  describe "sync all/3" do
    @payload load_event_fixture("issues_opened")

    test "creates missing, updates existing tasks for each project associated with the github repo" do
      user = insert(:user)
      %{github_repo: github_repo} = github_issue = insert(:github_issue)

      %{"issue" => %{"body" => issue_body}} = @payload

      [%{project: project_1}, _, _] = project_github_repos =
        insert_list(3, :project_github_repo, github_repo: github_repo)

      task_1 = insert(:task, project: project_1, github_issue: github_issue, github_repo: github_repo, user: user)

      project_ids = project_github_repos |> Enum.map(&Map.get(&1, :project_id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      {:ok, tasks} = github_issue |> IssueTaskSyncer.sync_all(user, @payload)

      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.markdown == issue_body
        assert task.github_issue_id == github_issue.id
      end)

      task_ids = tasks |> Enum.map(&Map.get(&1, :id))
      assert task_1.id in task_ids
    end

    test "fails on validation errors" do
      %{github_repo: github_repo} = github_issue = insert(:github_issue)

      bad_payload = @payload |> put_in(~w(issue title), nil)

      %{project: project} =
        insert(:project_github_repo, github_repo: github_repo)

      %{user: user} = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo)

      insert(:task_list, project: project, inbox: true)

      {:error, {tasks, errors}} =
        github_issue |> IssueTaskSyncer.sync_all(user, bad_payload)

      assert tasks |> Enum.count == 0
      assert errors |> Enum.count == 1
    end
  end
end

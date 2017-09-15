defmodule CodeCorps.GitHub.Event.Issues.TaskSyncerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.Issues.TaskSyncer,
    Project,
    Repo,
    Task
  }

  describe "sync all/3" do
    @payload load_event_fixture("issues_opened")

    test "creates missing, updates existing tasks for each project associated with the github repo" do
      user = insert(:user)
      github_repo = insert(:github_repo)

      %{"issue" => %{"number" => issue_number, "body" => issue_body}} = @payload

      [%{project: project_1}, _, _] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      task_1 = insert(:task, project: project_1, github_repo: github_repo, user: user, github_issue_number: issue_number)

      project_ids = project_github_repos |> Enum.map(&Map.get(&1, :project_id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      {:ok, tasks} = %{github_repo | project_github_repos: project_github_repos}
      |> TaskSyncer.sync_all(user, @payload)

      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.markdown == issue_body
        assert task.github_issue_number == issue_number
      end)

      task_ids = tasks |> Enum.map(&Map.get(&1, :id))
      assert task_1.id in task_ids
    end
  end
end

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
      projects = insert_list(3, :project)
      github_repo = insert(:github_repo)
      github_issue = insert(
        :github_issue,
        github_repo: github_repo,
        github_updated_at: DateTime.utc_now |> Timex.shift(hours: 1)
      )

      projects |> Enum.each(&insert(:task_list, project: &1, inbox: true))

      projects
      |> Enum.each(&insert(:project_github_repo, project: &1, github_repo: github_repo))

      %{github_issue: github_issue, github_repo: github_repo, projects: projects, user: user}
    end

    test "creates missing, updates existing tasks for each project associated with the github repo" do
      %{
        github_issue: github_issue,
        github_repo: github_repo,
        projects: [project_1 | _] = projects,
        user: user
      } = setup_test_data()

      existing_task =
        insert(:task, project: project_1, github_issue: github_issue, github_repo: github_repo, user: user)

      {:ok, tasks} = github_issue |> IssueTaskSyncer.sync_all(user)

      assert Repo.aggregate(Task, :count, :id) == projects |> Enum.count
      assert tasks |> Enum.count == projects |> Enum.count

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.markdown == github_issue.body
        assert task.github_issue_id == github_issue.id
      end)

      assert existing_task.id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "sets task :modified_from to 'github'" do
      %{github_issue: github_issue, user: user} = setup_test_data()
      {:ok, tasks} = github_issue |> IssueTaskSyncer.sync_all(user)
      assert tasks |> Enum.all?(fn task -> task.modified_from == "github" end)
    end

    test "fails on validation errors" do
      %{github_repo: github_repo} = github_issue = insert(:github_issue, title: nil)

      %{project: project} =
        insert(:project_github_repo, github_repo: github_repo)

      %{user: user} = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo)

      insert(:task_list, project: project, inbox: true)

      {:error, {tasks, errors}} = github_issue |> IssueTaskSyncer.sync_all(user)

      assert tasks |> Enum.count == 0
      assert errors |> Enum.count == 1
    end
  end
end

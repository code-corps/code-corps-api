defmodule CodeCorps.GitHub.Sync.PullRequest.TaskTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    Project,
    Repo,
    Task
  }
  alias CodeCorps.GitHub.Sync.PullRequest.Task, as: PullRequestTaskSyncer

  describe "sync all/3" do
    @payload load_event_fixture("pull_request_opened")

    test "creates missing, updates existing tasks for each project associated with the github repo" do
      user = insert(:user)
      %{github_repo: github_repo} = github_pull_request = insert(:github_pull_request)

      %{"pull_request" => %{"body" => pull_request_body}} = @payload

      [%{project: project_1}, _, _] = project_github_repos =
        insert_list(3, :project_github_repo, github_repo: github_repo)

      task_1 = insert(:task, project: project_1, github_pull_request: github_pull_request, github_repo: github_repo, user: user)

      project_ids = project_github_repos |> Enum.map(&Map.get(&1, :project_id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      {:ok, tasks} = github_pull_request |> PullRequestTaskSyncer.sync_all(user, @payload)

      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.markdown == pull_request_body
        assert task.github_pull_request_id == github_pull_request.id
      end)

      task_ids = tasks |> Enum.map(&Map.get(&1, :id))
      assert task_1.id in task_ids
    end

    test "fails on validation errors" do
      %{github_repo: github_repo} = github_pull_request = insert(:github_pull_request)

      bad_payload = @payload |> put_in(~w(pull_request title), nil)

      %{project: project} =
        insert(:project_github_repo, github_repo: github_repo)

      %{user: user} = insert(:task, project: project, github_pull_request: github_pull_request, github_repo: github_repo)

      insert(:task_list, project: project, inbox: true)

      {:error, {tasks, errors}} =
        github_pull_request |> PullRequestTaskSyncer.sync_all(user, bad_payload)

      assert tasks |> Enum.count == 0
      assert errors |> Enum.count == 1
    end
  end
end

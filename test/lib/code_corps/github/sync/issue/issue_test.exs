defmodule CodeCorps.GitHub.Sync.IssueTest do
  @moduledoc false

  use CodeCorps.BackgroundProcessingCase
  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Sync.Issue,
    Project,
    Repo,
    Task,
    User
  }

  describe "sync/2" do
    @payload load_event_fixture("issues_opened")

    test "with unmatched user, creates user, creates task for each project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "number" => number,
          "user" => %{"id" => user_github_id}
        } = issue,
        "repository" => %{"id" => repo_github_id}
      } = @payload

      github_repo = insert(:github_repo, github_id: repo_github_id)

      project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      changes = %{repo: github_repo}

      {:ok, %{tasks: tasks}} = Issue.sync(changes, issue) |> Repo.transaction

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      tasks |> Enum.each(fn task ->
        task = task |> Repo.preload(:github_issue)
        assert task.user_id == user.id
        assert task.github_issue_id
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue.number == number
        assert task.status == "open"
        assert task.order
      end)
    end

    test "with matched user, creates or updates task for each project associated to github repo" do
      %{
        "issue" => %{"id" => issue_github_id, "body" => markdown, "title" => title, "number" => number, "user" => %{"id" => user_github_id}} = issue,
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)
      github_issue = insert(:github_issue, github_id: issue_github_id, number: number, github_repo: github_repo)

      [%{project: project} | _rest] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      %{id: existing_task_id} =
        insert(:task, project: project, user: user, github_repo: github_repo, github_issue: github_issue)

      changes = %{repo: github_repo}

      {:ok, %{tasks: tasks}} = Issue.sync(changes, issue) |> Repo.transaction

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        task = task |> Repo.preload(:github_issue)
        assert task.github_issue_id == github_issue.id
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue.number == number
        assert task.status == "open"
        assert task.order
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "for a new pull request, updates relevant records" do
      %{
        "issue" => %{"id" => issue_github_id, "body" => markdown, "title" => title, "number" => number, "user" => %{"id" => user_github_id}} = issue,
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)
      github_issue = insert(:github_issue, github_id: issue_github_id, number: number, github_repo: github_repo)

      [%{project: project} | _rest] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, pull_requests: true)
      end)

      %{id: existing_task_id} =
        insert(:task, project: project, user: user, github_repo: github_repo, github_issue: github_issue)

      # Fake syncing of pull request
      github_pull_request = insert(:github_pull_request, github_repo: github_repo)

      changes = %{repo: github_repo, github_pull_request: github_pull_request}

      {:ok, %{tasks: tasks}} = Issue.sync(changes, issue) |> Repo.transaction

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        task = task |> Repo.preload(github_issue: :github_pull_request)
        assert task.github_issue_id == github_issue.id
        assert task.github_issue.github_pull_request.id == github_pull_request.id
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue.number == number
        assert task.status == "open"
        assert task.order
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end
  end
end

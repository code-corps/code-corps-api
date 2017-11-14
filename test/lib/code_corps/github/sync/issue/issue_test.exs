defmodule CodeCorps.GitHub.Sync.IssueTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Sync.Issue,
    Repo,
    Task,
    User
  }

  describe "sync/2" do
    @payload load_event_fixture("issues_opened")

    test "with unmatched user, creates user, creates task for project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "number" => number,
          "user" => %{"id" => user_github_id}
        } = issue,
        "repository" => %{"id" => repo_github_id}
      } = @payload

      github_repo = insert(:github_repo, github_id: repo_github_id)

      project = insert(:project)
      insert(:project_github_repo, github_repo: github_repo, project: project)
      insert(:task_list, project: project, inbox: true)

      changes = %{repo: github_repo}

      {:ok, %{task: task}} = Issue.sync(changes, issue) |> Repo.transaction

      assert Repo.aggregate(Task, :count, :id) == 1

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      task = task |> Repo.preload(:github_issue)
      assert task.user_id == user.id
      assert task.github_issue_id
      assert task.github_repo_id == github_repo.id
      assert task.project_id == project.id
      assert task.markdown == markdown
      assert task.title == title
      assert task.github_issue.number == number
      assert task.status == "open"
      assert task.order
    end

    test "with matched user, creates or updates task for project associated to github repo" do
      %{
        "issue" => %{"id" => issue_github_id, "body" => markdown, "title" => title, "number" => number, "user" => %{"id" => user_github_id}} = issue,
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)
      github_issue = insert(:github_issue, github_id: issue_github_id, number: number, github_repo: github_repo)

      project = insert(:project)
      insert(:project_github_repo, github_repo: github_repo, project: project)
      insert(:task_list, project: project, inbox: true)

      existing_task = insert(:task, project: project, user: user, github_repo: github_repo, github_issue: github_issue)

      changes = %{repo: github_repo}

      {:ok, %{task: task}} = Issue.sync(changes, issue) |> Repo.transaction

      assert Repo.aggregate(Task, :count, :id) == 1

      task = task |> Repo.preload(:github_issue)
      assert task.github_issue_id == github_issue.id
      assert task.github_repo_id == github_repo.id
      assert task.project_id == project.id
      assert task.markdown == markdown
      assert task.title == title
      assert task.github_issue.number == number
      assert task.status == "open"
      assert task.order

      assert existing_task.id == task.id
    end

    test "for a new pull request, updates relevant records" do
      %{
        "issue" => %{"id" => issue_github_id, "body" => markdown, "title" => title, "number" => number, "user" => %{"id" => user_github_id}} = issue,
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)
      github_issue = insert(:github_issue, github_id: issue_github_id, number: number, github_repo: github_repo)

      project = insert(:project)
      insert(:project_github_repo, github_repo: github_repo, project: project)
      task_list = insert(:task_list, project: project, pull_requests: true)

      existing_task = insert(:task, project: project, user: user, github_repo: github_repo, github_issue: github_issue)

      # Fake syncing of pull request
      github_pull_request = insert(:github_pull_request, github_repo: github_repo)

      changes = %{repo: github_repo, github_pull_request: github_pull_request}

      {:ok, %{task: task}} = Issue.sync(changes, issue) |> Repo.transaction

      assert Repo.aggregate(Task, :count, :id) == 1

      task = task |> Repo.preload(github_issue: :github_pull_request)
      assert task.github_issue_id == github_issue.id
      assert task.github_issue.github_pull_request.id == github_pull_request.id
      assert task.github_repo_id == github_repo.id
      assert task.project_id == project.id
      assert task.markdown == markdown
      assert task.title == title
      assert task.github_issue.number == number
      assert task.status == "open"
      assert task.order
      assert task.task_list_id == task_list.id

      assert existing_task.id == task.id
    end
  end
end

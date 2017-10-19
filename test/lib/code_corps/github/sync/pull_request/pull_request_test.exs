defmodule CodeCorps.GitHub.Sync.PullRequestTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Sync.PullRequest,
    Project,
    Repo,
    Task,
    User
  }

  describe "handle/2" do
    @payload load_event_fixture("pull_request_opened")

    test "with unmatched user, creates user, creates task for each project associated to github repo" do
      %{
        "pull_request" => %{
          "body" => markdown, "title" => title, "number" => number,
          "user" => %{"id" => user_github_id}
        },
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

      {:ok, tasks} = PullRequest.sync(@payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      tasks |> Enum.each(fn task ->
        task = task |> Repo.preload(:github_pull_request)
        assert task.user_id == user.id
        assert task.github_pull_request_id
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_pull_request.number == number
        assert task.status == "open"
      end)
    end

    test "with unmatched user, returns error if unmatched repository" do
      assert PullRequest.sync(@payload) == {:error, :repository_not_found}
      refute Repo.one(User)
    end

    test "with matched user, creates or updates task for each project associated to github repo" do
      %{
        "pull_request" => %{"id" => pull_request_github_id, "body" => markdown, "title" => title, "number" => number, "user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)
      github_pull_request = insert(:github_pull_request, github_id: pull_request_github_id, github_repo: github_repo)

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
        insert(:task, project: project, user: user, github_repo: github_repo, github_pull_request: github_pull_request)

      {:ok, tasks} = PullRequest.sync(@payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        task = task |> Repo.preload(:github_pull_request)
        assert task.github_pull_request_id == github_pull_request.id
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_pull_request.number == number
        assert task.status == "open"
        assert task.order
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "with matched user, returns error if unmatched repository" do
      %{"pull_request" => %{"user" => %{"id" => user_github_id}}} = @payload
      insert(:user, github_id: user_github_id)

      assert PullRequest.sync(@payload) == {:error, :repository_not_found}
    end
  end
end

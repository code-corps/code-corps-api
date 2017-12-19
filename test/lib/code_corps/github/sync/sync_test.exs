defmodule CodeCorps.GitHub.SyncTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers
  import Ecto.Query, only: [where: 3]

  alias CodeCorps.{
    Comment,
    GitHub.Sync,
    GithubAppInstallation,
    GithubComment,
    GithubIssue,
    GithubPullRequest,
    GithubRepo,
    GithubUser,
    Repo,
    Task,
    TaskList,
    User
  }

  describe "installation_repositories_event/1 added" do

    @payload load_event_fixture("installation_repositories_added")

    test "syncs_correctly when adding" do
      %{"installation" => %{
        "id" => installation_id
        },
        "repositories_added" => added_repos,
        "sender" => %{"id" => _user_id}
      } = @payload

      project = insert(:project)
      user =  insert(:user)

      insert(:github_app_installation, github_id: installation_id, project: project, user: user)

      {:ok, _repos} = Sync.installation_repositories_event(@payload)

      repo_ids = Enum.map(added_repos, &Map.get(&1, "id"))

      for repo <- Repo.all(GithubRepo) do
        assert repo.github_id in repo_ids
      end

      assert Repo.aggregate(GithubRepo, :count, :id) == 2
      assert Repo.aggregate(GithubAppInstallation, :count, :id) == 1
    end

    test "can fail when installation not found" do
      assert {:error, :unmatched_installation, %{}} == @payload |> Sync.installation_repositories_event()
    end

    test "fails with validation errors when syncing repos" do
      %{"installation" => %{
        "id" => installation_id
        },
        "repositories_added" => repos,
        "sender" => %{"id" => _user_id}
      } = @payload

      project = insert(:project)
      user =  insert(:user)
      insert(:github_app_installation, github_id: installation_id, project: project, user: user)


      corrupt_repos = Enum.map(repos, &(Map.put(&1,"name", "")))

      corrupted_payload = Map.put(@payload, "repositories_added", corrupt_repos)

      assert {:error, :validation_error_on_syncing_repos, %{}} == corrupted_payload |> Sync.installation_repositories_event()
    end
  end

  describe "installation_repositories_event/1 removed" do
    @payload load_event_fixture("installation_repositories_removed")

    test "syncs_correctly when removing" do
      %{"installation" => %{
        "id" => installation_id
        },
        "repositories_removed" => removed_repos
        } = @payload

      project = insert(:project)
      user =  insert(:user)
      installation = insert(:github_app_installation, github_id: installation_id, project: project, user: user)

      for repo <- removed_repos do
        insert(:github_repo, github_id: repo["id"], github_app_installation: installation)
      end

      assert Repo.aggregate(GithubRepo, :count, :id) == 2
      assert Repo.aggregate(GithubAppInstallation, :count, :id) == 1


      {:ok, _repos} = Sync.installation_repositories_event(@payload)

      assert Repo.aggregate(GithubRepo, :count, :id) == 0
    end
  end

  describe "issue_comment_event/1 on comment created for pull request" do
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

      project = insert(:project)
      github_repo = insert(:github_repo, github_id: repo_github_id, project: project)
      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, inbox: true)
      insert(:task_list, project: project, pull_requests: true)

      {:ok, comment} = Sync.issue_comment_event(@payload)

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

  describe "sync_repo/1" do
    defp setup_test_repo do
      project = insert(:project)
      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, inbox: true)
      insert(:task_list, project: project, pull_requests: true)

      owner = "baxterthehacker"
      repo = "public-repo"
      github_app_installation = insert(:github_app_installation, github_account_login: owner)

      insert(
        :github_repo,
        github_app_installation: github_app_installation,
        name: repo,
        github_account_id: 6_752_317,
        github_account_avatar_url: "https://avatars3.githubusercontent.com/u/6752317?v=4",
        github_account_type: "User",
        github_id: 35_129_377,
        project: project)
    end

    test "syncs and resyncs with the project repo" do
      github_repo = setup_test_repo()

      # Sync the first time

      Sync.sync_repo(github_repo)

      repo = Repo.one(GithubRepo)

      assert repo.syncing_pull_requests_count == 4
      assert repo.syncing_issues_count == 8
      assert repo.syncing_comments_count == 12

      assert Repo.aggregate(GithubComment, :count, :id) == 12
      assert Repo.aggregate(GithubIssue, :count, :id) == 8
      assert Repo.aggregate(GithubPullRequest, :count, :id) == 4
      assert Repo.aggregate(GithubUser, :count, :id) == 10
      assert Repo.aggregate(Comment, :count, :id) == 12
      assert Repo.aggregate(Task, :count, :id) == 8
      assert Repo.aggregate(User, :count, :id) == 13

      # Sync a second time – should run without trouble

      Sync.sync_repo(github_repo)

      repo = Repo.one(GithubRepo)

      assert repo.syncing_pull_requests_count == 4
      assert repo.syncing_issues_count == 8
      assert repo.syncing_comments_count == 12

      assert Repo.aggregate(GithubComment, :count, :id) == 12
      assert Repo.aggregate(GithubIssue, :count, :id) == 8
      assert Repo.aggregate(GithubPullRequest, :count, :id) == 4
      assert Repo.aggregate(GithubUser, :count, :id) == 10
      assert Repo.aggregate(Comment, :count, :id) == 12
      assert Repo.aggregate(Task, :count, :id) == 8
      assert Repo.aggregate(User, :count, :id) == 13
    end

    # coupled to fixtures. depends on
    # - fixtures/github/endpoints/issues.json on having at least 4 issues
    #   linked to pull requests
    # - fixtures/github/endpoints/pulls.json having payloads for those 4 pull
    #   requests (matched by "number")
    test "matches github issue with github pull request correctly" do
      {:ok, github_repo} = setup_test_repo() |> Sync.sync_repo

      %GithubRepo{github_issues: github_issues} =
        GithubRepo |> Repo.get(github_repo.id) |> Repo.preload(:github_issues)

      linked_issues =
        github_issues
        |> Enum.reject(fn i -> is_nil(i.github_pull_request_id) end)

      assert linked_issues |> Enum.count == 4
    end

    @tag acceptance: true
    test "syncs with the project repo with the real API" do
      github_repo = setup_coderly_repo()

      with_real_api do
        Sync.sync_repo(github_repo)
      end

      repo = Repo.one(GithubRepo)

      assert repo.syncing_pull_requests_count == 1
      assert repo.syncing_issues_count == 3
      assert repo.syncing_comments_count == 2

      assert Repo.aggregate(GithubComment, :count, :id) == 2
      assert Repo.aggregate(GithubIssue, :count, :id) == 3
      assert Repo.aggregate(GithubPullRequest, :count, :id) == 1
      assert Repo.aggregate(GithubUser, :count, :id) == 2
      assert Repo.aggregate(Comment, :count, :id) == 2
      assert Repo.aggregate(Task, :count, :id) == 3
      assert Repo.aggregate(User, :count, :id) == 2

      # Tasks closed more than 30 days ago
      archived_tasks =
        Task
        |> where([object], is_nil(object.task_list_id))
        |> Repo.all()

      %TaskList{tasks: inbox_tasks} =
        TaskList |> Repo.get_by(inbox: true) |> Repo.preload(:tasks)
      %TaskList{tasks: pull_requests_tasks} =
        TaskList |> Repo.get_by(pull_requests: true) |> Repo.preload(:tasks)

      assert Enum.count(archived_tasks) == 1
      assert Enum.count(inbox_tasks) == 1
      assert Enum.count(pull_requests_tasks) == 1
    end
  end
end

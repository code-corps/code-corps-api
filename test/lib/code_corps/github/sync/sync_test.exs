defmodule CodeCorps.GitHub.SyncTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers
  import Ecto.Query, only: [where: 3]

  alias CodeCorps.{
    Comment,
    GitHub.Adapters,
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

  alias Ecto.Changeset

  describe "pull_request_event" do
    ["pull_request_opened","pull_request_closed","pull_request_edited", "pull_request_opened_by_bot","pull_request_reopened"]
    |> Enum.each(fn payload_name ->
    @event payload_name
      test  "runs succesfully when " <> @event do
        payload = load_event_fixture(@event)
        project = insert(:project)
        insert(:github_repo, github_id: payload["repository"]["id"], project: project)
        insert(:task_list, project: project, done: true)
        insert(:task_list, project: project, inbox: true)
        insert(:task_list, project: project, pull_requests: true)
        {:ok, _map} = Sync.pull_request_event(payload)
      end

      test "fails if repo not found when " <> @event do
        payload = load_event_fixture(@event)
        {:error, :repo_not_found} = Sync.pull_request_event(payload)
      end

      test "fails if api errors out when " <> @event do
        payload = load_event_fixture(@event)
        project = insert(:project)
        insert(:github_repo, github_id: payload["repository"]["id"], project: project)
        insert(:task_list, project: project, done: true)
        insert(:task_list, project: project, inbox: true)
        insert(:task_list, project: project, pull_requests: true)

        with_mock_api(CodeCorps.GitHub.FailureAPI) do
          assert {:error, :fetching_issue, _error} = Sync.pull_request_event(payload)
        end
      end

      test "fails with validation error if pull request is invalid when " <> @event do
        payload = load_event_fixture(@event)
        project = insert(:project)
        insert(:github_repo, github_id: payload["repository"]["id"], project: project)
        insert(:task_list, project: project, done: true)
        insert(:task_list, project: project, inbox: true)
        insert(:task_list, project: project, pull_requests: true)

        %{"pull_request" => pull} = payload
        corrupt_pull =  %{pull | "created_at" => nil,  "updated_at" => nil, "html_url" => nil, "locked" => nil,
        "number" => nil, "state" =>  nil, "title" => nil }
        corrupt_pull_request = Map.put(payload, "pull_request", corrupt_pull)
        {:error, :validating_github_pull_request, _changeset} = Sync.pull_request_event(corrupt_pull_request)
      end

    end)
  end

  describe "pull_request_event/1 " do
    @payload load_event_fixture("pull_request_opened")


    test "fails with validation error if task_list isn't found" do
      project = insert(:project)
      insert(:github_repo, github_id: @payload["repository"]["id"], project: project)
      {:error, :validating_task, _changeset} = Sync.pull_request_event(@payload)
    end
  end


  # Some clauses defined seem difficult or impossible to reach so their tests were omitted
  # - {:error, :validation_error_on_syncing_installation, Changeset.t()}
  # - {:error, :validation_error_on_marking_installation_processed, Changeset.t()}
  # - {:error, :unexpected_transaction_outcome, any}
  # However, if these clauses can be caused by some updates upstream we should cover them with tests

  describe "installation_event" do

    @payload load_event_fixture("installation_created")

    test "syncs_correctly_with valid data" do
      %{"installation" => %{"id" => installation_id}} = @payload

      assert Repo.aggregate(GithubAppInstallation, :count, :id) == 0

      {:ok, installation} = Sync.installation_event(@payload)


      assert Repo.aggregate(GithubAppInstallation, :count, :id) == 1
      assert installation.github_id == installation_id
    end

    test "fails if multiple installations are unprocessed" do
      user = insert(:user, github_id: @payload["sender"]["id"])
      project = insert(:project)
      attrs = %{project: project, user: user, sender_github_id: user.id, github_id: nil}
      insert(:github_app_installation, attrs)
      insert(:github_app_installation, attrs)

      {:error, :multiple_unprocessed_installations_found} = Sync.installation_event(@payload)
    end

    test "fails on syncing api error" do
      with_mock_api(CodeCorps.GitHub.FailureAPI) do
        assert {:error, :github_api_error_on_syncing_repos, _error} = Sync.installation_event(@payload)
      end
    end
  end



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
      assert {:error, :unmatched_installation} == @payload |> Sync.installation_repositories_event()
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
    @issue_comment_preloads [
      :user,
      [task: :user],
      [github_comment: [github_issue: [:github_pull_request, :github_repo]]]
    ]

    @payload load_event_fixture("issue_comment_created_on_pull_request")

    test "syncs correctly" do
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

      %{
        github_comment: %{
          github_issue: %{
            github_pull_request: github_pull_request
          } = github_issue
        } = github_comment,
        task: task
      } = comment = comment |> Repo.preload(@issue_comment_preloads)

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

    test "can fail when finding repo" do
      assert {:error, :repo_not_found} == @payload |> Sync.issue_comment_event()
    end

    test "can fail when fetching pull request" do
      insert(:github_repo, github_id: @payload["repository"]["id"])

      with_mock_api(CodeCorps.GitHub.FailureAPI) do
        assert {:error, :fetching_pull_request, %CodeCorps.GitHub.APIError{}} =
          @payload |> Sync.issue_comment_event()
      end
    end

    test "can fail on github pull request validation" do
      defmodule InvalidPullRequestAPI do
        @moduledoc false

        def request(:get, "https://api.github.com/repos/baxterthehacker/public-repo/pulls/1", _, _, _) do
          {:ok, body} =
            "pull_request"
            |> load_endpoint_fixture()
            |> Map.put("number", nil)
            |> Poison.encode
          {:ok, %HTTPoison.Response{status_code: 200, body: body}}
        end
        def request(method, endpoint, body, headers, options) do
          CodeCorps.GitHub.SuccessAPI.request(method, endpoint, body, headers, options)
        end
      end

      insert(:github_repo, github_id: @payload["repository"]["id"])

      with_mock_api(InvalidPullRequestAPI) do
        assert {:error, :validating_github_pull_request, %Changeset{} = changeset} =
          @payload |> Sync.issue_comment_event()
          refute changeset.valid?
      end
    end

    test "can fail on github user validation for github pull request" do
      defmodule InvalidUserAPI do
        @moduledoc false

        def request(:get, "https://api.github.com/repos/baxterthehacker/public-repo/pulls/1", _, _, _) do
          {:ok, body} =
            "pull_request"
            |> load_endpoint_fixture()
            |> Kernel.put_in(["user", "login"], nil)
            |> Poison.encode
          {:ok, %HTTPoison.Response{status_code: 200, body: body}}
        end
        def request(method, endpoint, body, headers, options) do
          CodeCorps.GitHub.SuccessAPI.request(method, endpoint, body, headers, options)
        end
      end

      insert(:github_repo, github_id: @payload["repository"]["id"])

      with_mock_api(InvalidUserAPI) do
        assert {
          :error,
          :validating_github_user_on_github_pull_request,
          %Changeset{} = changeset
        } = @payload |> Sync.issue_comment_event()

        refute changeset.valid?
      end
    end

    test "can fail on github issue validation" do
      insert(:github_repo, github_id: @payload["repository"]["id"])
      assert {:error, :validating_github_issue, %Changeset{} = changeset} =
        @payload
        |> Kernel.put_in(["issue", "number"], nil)
        |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail on github user validation for github issue" do
      insert(:github_repo, github_id: @payload["repository"]["id"])
      assert {
        :error,
        :validating_github_user_on_github_issue,
        %Changeset{} = changeset
      } =
        @payload
        |> Kernel.put_in(["issue", "user", "login"], nil)
        |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail on task user validation" do
      insert(:github_repo, github_id: @payload["repository"]["id"])

      # setup data to trigger a unique constraint
      email = "taken@mail.com"
      insert(:user, email: email)
      payload = @payload |> Kernel.put_in(["issue", "user", "email"], email)

      assert {:error, :validating_task_user, %Changeset{} = changeset} =
        payload |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail if task matched with multiple users" do
      github_repo =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      attrs =
        @payload["issue"]
        |> Adapters.Issue.to_issue()
        |> Map.put(:github_repo, github_repo)

      github_issue = insert(:github_issue, attrs)
      # creates a user for each task, which should never happen normally
      insert_pair(:task, github_issue: github_issue)

      assert {:error, :multiple_task_users_match} ==
        @payload |> Sync.issue_comment_event()
    end

    test "can fail on task validation" do
      insert(:github_repo, github_id: @payload["repository"]["id"])

      # validation is triggered due to missing task list

      assert {:error, :validating_task, %Changeset{} = changeset} =
        @payload |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail on github comment validation" do
      %{project: project} =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, pull_requests: true)

      assert {:error, :validating_github_comment, %Changeset{} = changeset} =
        @payload
        |> Kernel.put_in(["comment", "url"], nil)
        |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail on github user validation for github comment" do
      %{project: project} =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, pull_requests: true)

      assert {
        :error,
        :validating_github_user_on_github_comment,
        %Changeset{} = changeset
      } =
        @payload
        |> Kernel.put_in(["comment", "user", "login"], nil)
        |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail on comment user validation" do
      %{project: project} =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, pull_requests: true)

      # setup data to trigger a unique constraint
      email = "taken@mail.com"
      insert(:user, email: email)

      assert {:error, :validating_comment_user, %Changeset{} = changeset} =
        @payload
        |> Kernel.put_in(["comment", "user", "email"], email)
        |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail if commment matched with multiple users" do
      %{project: project} = github_repo =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, pull_requests: true)

      attrs =
        @payload["comment"]
        |> Adapters.Comment.to_github_comment()
        |> Map.put(:github_repo, github_repo)

      github_comment = insert(:github_comment, attrs)
      # creates a user for each comment, which should never happen normally
      insert_pair(:comment, github_comment: github_comment)

      assert {:error, :multiple_comment_users_match} ==
        @payload |> Sync.issue_comment_event()
    end
  end

  describe "issue_comment_event/1 on comment created for regular issue" do
    @payload load_event_fixture("issue_comment_created")

    test "syncs correctly" do
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
      insert(:github_repo, github_id: repo_github_id, project: project)
      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, inbox: true)

      {:ok, comment} = Sync.issue_comment_event(@payload)

      assert Repo.aggregate(GithubComment, :count, :id) == 1
      assert Repo.aggregate(GithubIssue, :count, :id) == 1
      assert Repo.aggregate(GithubPullRequest, :count, :id) == 0
      assert Repo.aggregate(Comment, :count, :id) == 1
      assert Repo.aggregate(Task, :count, :id) == 1

      issue_user = Repo.get_by(User, github_id: issue_user_github_id)
      assert issue_user

      comment_user = Repo.get_by(User, github_id: comment_user_github_id)
      assert comment_user

      %{
        github_comment: %{
          github_issue: %{
            github_pull_request: github_pull_request
          } = github_issue
        } = github_comment,
        task: task
      } = comment = comment |> Repo.preload(@issue_comment_preloads)

      assert github_comment.github_id == comment_github_id

      assert github_issue.github_id == issue_github_id
      assert github_issue.body == issue_body
      assert github_issue.number == issue_number
      assert github_pull_request == nil

      assert task.markdown == issue_body
      assert task.project_id == project.id
      assert task.user.github_id == issue_user_github_id
      assert task.user_id == issue_user.id

      assert comment.markdown == comment_body
      assert comment.user_id == comment_user.id
      assert comment.user.github_id == comment_user_github_id
    end

    test "can fail when finding repo" do
      assert {:error, :repo_not_found} == @payload |> Sync.issue_comment_event()
    end

    test "can fail on github issue validation" do
      insert(:github_repo, github_id: @payload["repository"]["id"])
      assert {:error, :validating_github_issue, %Changeset{} = changeset} =
        @payload
        |> Kernel.put_in(["issue", "number"], nil)
        |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail on github user validation for github issue" do
      insert(:github_repo, github_id: @payload["repository"]["id"])
      assert {
        :error,
        :validating_github_user_on_github_issue,
        %Changeset{} = changeset
      } =
        @payload
        |> Kernel.put_in(["issue", "user", "login"], nil)
        |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail on task user validation" do
      insert(:github_repo, github_id: @payload["repository"]["id"])

      # setup data to trigger a unique constraint
      email = "taken@mail.com"
      insert(:user, email: email)
      payload = @payload |> Kernel.put_in(["issue", "user", "email"], email)

      assert {:error, :validating_task_user, %Changeset{} = changeset} =
        payload |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail if task matched with multiple users" do
      github_repo =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      attrs =
        @payload["issue"]
        |> Adapters.Issue.to_issue()
        |> Map.put(:github_repo, github_repo)

      github_issue = insert(:github_issue, attrs)
      # creates a user for each task, which should never happen normally
      insert_pair(:task, github_issue: github_issue)

      assert {:error, :multiple_task_users_match} ==
        @payload |> Sync.issue_comment_event()
    end

    test "can fail on task validation" do
      insert(:github_repo, github_id: @payload["repository"]["id"])

      # validation is triggered due to missing task list

      assert {:error, :validating_task, %Changeset{} = changeset} =
        @payload |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail on github comment validation" do
      %{project: project} =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, inbox: true)

      assert {:error, :validating_github_comment, %Changeset{} = changeset} =
        @payload
        |> Kernel.put_in(["comment", "url"], nil)
        |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail on github user validation for github comment" do
      %{project: project} =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, inbox: true)

      assert {
        :error,
        :validating_github_user_on_github_comment,
        %Changeset{} = changeset
      } =
        @payload
        |> Kernel.put_in(["comment", "user", "login"], nil)
        |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail on comment user validation" do
      %{project: project} =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, inbox: true)

      # setup data to trigger a unique constraint
      email = "taken@mail.com"
      insert(:user, email: email)

      assert {:error, :validating_comment_user, %Changeset{} = changeset} =
        @payload
        |> Kernel.put_in(["comment", "user", "email"], email)
        |> Sync.issue_comment_event()

      refute changeset.valid?
    end

    test "can fail if commment matched with multiple users" do
      %{project: project} = github_repo =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      insert(:task_list, project: project, done: true)
      insert(:task_list, project: project, inbox: true)

      attrs =
        @payload["comment"]
        |> Adapters.Comment.to_github_comment()
        |> Map.put(:github_repo, github_repo)

      github_comment = insert(:github_comment, attrs)
      # creates a user for each comment, which should never happen normally
      insert_pair(:comment, github_comment: github_comment)

      assert {:error, :multiple_comment_users_match} ==
        @payload |> Sync.issue_comment_event()
    end
  end

  describe "issue_comment_event/1 on comment deleted" do
    test "syncs correctly" do
      %{"comment" => %{"id" => github_id}} = payload =
        load_event_fixture("issue_comment_deleted")

      github_comment = insert(:github_comment, github_id: github_id)
      comment = insert(:comment, github_comment: github_comment)

      {:ok, %{deleted_comments: [deleted_comment], deleted_github_comment: deleted_github_comment}}
        = payload |> Sync.issue_comment_event()

      assert deleted_comment.id == comment.id
      assert deleted_github_comment.id == github_comment.id
      assert Repo.aggregate(Comment, :count, :id) == 0
      assert Repo.aggregate(GithubComment, :count, :id) == 0
    end
  end

  describe "issue_event/1" do
    @payload load_event_fixture("issues_opened")

    test "with unmatched user, creates user, creates task for project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "number" => number,
          "user" => %{"id" => user_github_id}
        },
        "repository" => %{"id" => repo_github_id}
      } = @payload

      project = insert(:project)
      github_repo = insert(:github_repo, github_id: repo_github_id, project: project)
      insert(:task_list, project: project, inbox: true)

      {:ok, %Task{} = task} = @payload |> Sync.issue_event()
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
        "issue" => %{
          "id" => issue_github_id,
          "body" => markdown,
          "title" => title,
          "number" => number,
          "user" => %{"id" => user_github_id}
        } ,
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      project = insert(:project)
      github_repo = insert(:github_repo, github_id: repo_github_id, project: project)
      github_issue = insert(:github_issue, github_id: issue_github_id, number: number, github_repo: github_repo)

      insert(:task_list, project: project, inbox: true)

      existing_task = insert(:task, project: project, user: user, github_repo: github_repo, github_issue: github_issue)

      {:ok, %Task{} = task} = @payload |> Sync.issue_event()

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

    test "can fail when finding repo" do
      assert {:error, :repo_not_found} == @payload |> Sync.issue_event()
    end

    test "can fail on github issue validation" do
      insert(:github_repo, github_id: @payload["repository"]["id"])
      assert {:error, :validating_github_issue, %Changeset{} = changeset} =
        @payload
        |> Kernel.put_in(["issue", "number"], nil)
        |> Sync.issue_event()

      refute changeset.valid?
    end

    test "can fail on github user validation" do
      insert(:github_repo, github_id: @payload["repository"]["id"])
      assert {:error, :validating_github_user, %Changeset{} = changeset} =
        @payload
        |> Kernel.put_in(["issue", "user", "login"], nil)
        |> Sync.issue_event()

      refute changeset.valid?
    end

    test "can fail on user validation" do
      insert(:github_repo, github_id: @payload["repository"]["id"])

      # setup data to trigger a unique constraint
      email = "taken@mail.com"
      insert(:user, email: email)
      payload = @payload |> Kernel.put_in(["issue", "user", "email"], email)

      assert {:error, :validating_user, %Changeset{} = changeset} =
        payload |> Sync.issue_event()

      refute changeset.valid?
    end

    test "can fail if matched by multiple users" do
      github_repo =
        insert(:github_repo, github_id: @payload["repository"]["id"])

      attrs =
        @payload["issue"]
        |> Adapters.Issue.to_issue()
        |> Map.put(:github_repo, github_repo)

      github_issue = insert(:github_issue, attrs)
      # creates a user for each task, which should never happen normally
      insert_pair(:task, github_issue: github_issue)

      assert {:error, :multiple_task_users_match} ==
        @payload |> Sync.issue_event()
    end

    test "can fail on task validation" do
      insert(:github_repo, github_id: @payload["repository"]["id"])

      # validation is triggered due to missing task list

      assert {:error, :validating_task, %Changeset{} = changeset} =
        @payload |> Sync.issue_event()

      refute changeset.valid?
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

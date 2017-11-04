defmodule CodeCorps.GitHub.Event.PullRequestTest do
  @moduledoc false

  use CodeCorps.BackgroundProcessingCase
  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.PullRequest,
    GithubIssue,
    GithubPullRequest,
    Repo,
    Task,
    User
  }

  describe "handle/2" do
    @payload load_event_fixture("pull_request_opened") |> Map.put("action", "foo")

    test "returns error if action of the event is wrong" do
      assert {:error, :unexpected_action} == PullRequest.handle(@payload)
    end
  end

  @implemented_actions ~w(opened closed edited reopened)

  @implemented_actions |> Enum.each(fn action ->
    describe "handle/2 for PullRequest::#{action}" do
      @payload load_event_fixture("pull_request_#{action}")

      test "creates or updates associated records" do
        %{"repository" => %{"id" => repo_github_id}} = @payload

        github_repo = insert(:github_repo, github_id: repo_github_id)
        %{project: project} = insert(:project_github_repo, github_repo: github_repo)
        insert(:task_list, project: project, inbox: true)

        {:ok, %{github_pull_request: github_pull_request}} = PullRequest.handle(@payload)

        assert github_pull_request.github_repo_id == github_repo.id
        assert Repo.aggregate(GithubIssue, :count, :id) == 1
        assert Repo.aggregate(GithubPullRequest, :count, :id) == 1
        assert Repo.aggregate(Task, :count, :id) == 1
      end

      test "returns error if unmatched repository" do
        assert PullRequest.handle(@payload) == {:error, :repo_not_found}
        refute Repo.one(User)
      end

      test "returns error if payload is wrong" do
        assert {:error, :unexpected_payload} == PullRequest.handle(%{})
      end

      test "returns error if repo payload is wrong" do
        assert {:error, :unexpected_payload} == PullRequest.handle(@payload |> Map.put("repository", "foo"))
      end

      test "returns error if pull request payload is wrong" do
        assert {:error, :unexpected_payload} == PullRequest.handle(@payload |> Map.put("pull_request", "foo"))
      end
    end
  end)

  @unimplemented_actions ~w(
    assigned unassigned review_requested review_request_removed labeled
    unlabeled
  )

  @unimplemented_actions |> Enum.each(fn action ->
    describe "handle/2 for PullRequest::#{action}" do
      @payload %{
        "action" => action,
        "pull_request" => %{
          "id" => 1, "title" => "foo", "body" => "bar", "state" => "baz",
          "user" => %{"id" => "bat"}
        },
        "repository" => %{"id" => 2}
      }

      test "is not implemented" do
        assert PullRequest.handle(@payload) == {:error, :not_fully_implemented}
      end
    end
  end)
end

defmodule CodeCorps.GitHub.Event.IssuesTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GithubIssue,
    GitHub.Event.Issues,
    Repo,
    Task,
    User
  }

  @implemented_actions ~w(opened closed edited reopened)

  @implemented_actions |> Enum.each(fn action ->
    describe "handle/1 for Issues::#{action}" do
      @payload load_event_fixture("issues_#{action}")

      test "creates or updates associated records" do
        %{"repository" => %{"id" => repo_github_id}} = @payload

        github_repo = insert(:github_repo, github_id: repo_github_id)
        %{project: project} = insert(:project_github_repo, github_repo: github_repo)
        insert(:task_list, project: project, done: true)
        insert(:task_list, project: project, inbox: true)
        insert(:task_list, project: project, pull_requests: true)

        {:ok, %Task{}} = Issues.handle(@payload)

        assert Repo.aggregate(GithubIssue, :count, :id) == 1
        assert Repo.aggregate(Task, :count, :id) == 1
      end

      test "returns error if unmatched repository" do
        assert Issues.handle(@payload) == {:error, :repo_not_found}
        refute Repo.one(User)
      end

      test "returns error if payload is wrong" do
        assert {:error, :unexpected_payload} == Issues.handle(%{})
      end

      test "returns error if repo payload is wrong" do
        assert {:error, :unexpected_payload} == Issues.handle(@payload |> Map.put("repository", "foo"))
      end

      test "returns error if issue payload is wrong" do
        assert {:error, :unexpected_payload} == Issues.handle(@payload |> Map.put("issue", "foo"))
      end
    end
  end)
end

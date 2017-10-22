defmodule CodeCorps.GitHub.Sync.PullRequestTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Sync.PullRequest,
    Repo
  }

  describe "sync/2" do
    @pull_request_opened_payload load_event_fixture("pull_request_opened")

    test "with pull request in payload creates github pull request associated to github repo" do
      %{
        "pull_request" => %{
          "body" => body, "title" => title, "number" => number
        } = pull_request,
        "repository" => %{"id" => repo_github_id}
      } = @pull_request_opened_payload

      github_repo = insert(:github_repo, github_id: repo_github_id)

      {:ok, %{github_pull_request: github_pull_request}} =
        %{repo: github_repo}
        |> PullRequest.sync(pull_request)
        |> Repo.transaction

      assert github_pull_request.body == body
      assert github_pull_request.title == title
      assert github_pull_request.number == number
      assert github_pull_request.state == "open"
    end

    test "with pull request in changes creates github pull request associated to github repo" do
      %{
        "pull_request" => pull_request,
        "repository" => %{"id" => repo_github_id}
      } = @pull_request_opened_payload

      github_repo = insert(:github_repo, github_id: repo_github_id)

      {:ok, %{github_pull_request: github_pull_request}} =
        %{repo: github_repo, fetch_pull_request: pull_request}
        |> PullRequest.sync(pull_request)
        |> Repo.transaction

      assert github_pull_request.state == "open"
    end
  end
end

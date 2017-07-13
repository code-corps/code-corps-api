defmodule CodeCorps.GitHub.Event.Installation.ReposTest do
  @moduledoc false

  use CodeCorps.DbAccessCase
  use CodeCorps.GitHubCase

  import CodeCorps.Factories
  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubAppInstallation,
    GithubRepo,
    GitHub.Event.Installation.Repos,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.GithubRepo, as: GithubRepoAdapter

  @access_token "v1.1f699f1069f60xxx"
  @expires_at Timex.now() |> Timex.shift(hours: 1) |> DateTime.to_iso8601()
  @access_token_create_response %{"token" => @access_token, "expires_at" => @expires_at}

  @installation_repositories load_endpoint_fixture("installation_repositories")
  @forbidden load_endpoint_fixture("forbidden")

  @app_github_id 2

  describe "process_async/1" do
    @tag bypass: %{
      "/installation/repositories" => {200, @installation_repositories},
      "/installations/#{@app_github_id}/access_tokens" => {200, @access_token_create_response}
    }
    test "syncs repos by performing a diff using payload as master list, asynchronously" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      %{"repositories" => [matched_repo_payload, new_repo_payload]} = @installation_repositories
      matched_repo_attrs = matched_repo_payload |> GithubRepoAdapter.from_api
      new_repo_attrs = new_repo_payload |> GithubRepoAdapter.from_api

      unmatched_repo = insert(:github_repo, github_app_installation: installation)
      _matched_repo = insert(:github_repo, matched_repo_attrs |> Map.put(:github_app_installation, installation))

      {:ok, %GithubAppInstallation{state: intermediate_state}, task} =
        installation
        |> Repo.preload(:github_repos)
        |> Repos.process_async()

      assert intermediate_state == "processing"

      task |> Task.await

      %GithubAppInstallation{state: end_state} = Repo.one(GithubAppInstallation)

      assert end_state == "processed"

      # unmatched repo was on record, but not in the payload, so it got deleted
      refute Repo.get(GithubRepo, unmatched_repo.id)
      # matched repo was both on record and in the payload, so it got updated
      assert Repo.get_by(GithubRepo, matched_repo_attrs)
      # new_repo was not on record, but was in the payload, so it got created
      assert Repo.get_by(GithubRepo, new_repo_attrs)

      # ensure no other repos have been created
      assert GithubRepo |> Repo.aggregate(:count, :id) == 2
    end
  end

  describe "process/1" do
    @tag bypass: %{
      "/installation/repositories" => {200, @installation_repositories},
      "/installations/#{@app_github_id}/access_tokens" => {200, @access_token_create_response}
    }
    test "syncs repos by performing a diff using payload as master list" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      %{"repositories" => [matched_repo_payload, new_repo_payload]} = @installation_repositories
      matched_repo_attrs = matched_repo_payload |> GithubRepoAdapter.from_api
      new_repo_attrs = new_repo_payload |> GithubRepoAdapter.from_api

      unmatched_repo = insert(:github_repo, github_app_installation: installation)
      _matched_repo = insert(:github_repo, matched_repo_attrs |> Map.put(:github_app_installation, installation))

      installation |> Repo.preload(:github_repos) |> Repos.process()

      # unmatched repo was on record, but not in the payload, so it got deleted
      refute Repo.get(GithubRepo, unmatched_repo.id)
      # matched repo was both on record and in the payload, so it got updated
      assert Repo.get_by(GithubRepo, matched_repo_attrs)
      # new_repo was not on record, but was in the payload, so it got created
      assert Repo.get_by(GithubRepo, new_repo_attrs)

      # ensure no other repos have been created
      assert GithubRepo |> Repo.aggregate(:count, :id) == 2
    end

    @tag bypass: %{
      "/installation/repositories" => {403, @forbidden},
      "/installations/#{@app_github_id}/access_tokens" => {200, @access_token_create_response}
    }
    test "returns installation as errored if api error" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")
      {:error, %GithubAppInstallation{state: state}, %CodeCorps.GitHub.APIError{}} = Repos.process(installation)
      assert state == "errored"
    end

    @tag bypass: %{
      "/installation/repositories" => {200, @installation_repositories |> Map.put("repositories", ["foo"])},
      "/installations/#{@app_github_id}/access_tokens" => {200, @access_token_create_response}
    }
    test "returns installation as errored if payload incorrect" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")
      {:error, %GithubAppInstallation{state: state}, :invalid_repo_payload} = Repos.process(installation)
      assert state == "errored"
    end
  end
end

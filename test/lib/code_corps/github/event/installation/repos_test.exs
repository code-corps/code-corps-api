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

  describe "process/1" do
    @tag bypass: %{
      "/installation/repositories" => {200, @installation_repositories},
      "/installations/#{@app_github_id}/access_tokens" => {200, @access_token_create_response}
    }
    test "creates repos on master list, but not locally on record" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      {:ok, %GithubAppInstallation{} = updated_installation} = Repos.process(installation |> Repo.preload(:github_repos))

      assert updated_installation.state == "processed"
      assert updated_installation.github_repos |> Enum.count == 2

      [repo_1, repo_2] = updated_installation.github_repos
      %{"repositories" => [repo_1_payload, repo_2_payload]} = @installation_repositories

      attributes = [:github_id, :name, :github_account_id, :github_account_avatar_url, :github_account_login, :github_account_type]

      assert repo_1 |> Map.take(attributes) == repo_1_payload |> GithubRepoAdapter.from_api
      assert repo_2 |> Map.take(attributes) == repo_2_payload |> GithubRepoAdapter.from_api
    end

    @tag bypass: %{
      "/installation/repositories" => {200, @installation_repositories},
      "/installations/#{@app_github_id}/access_tokens" => {200, @access_token_create_response}
    }
    test "deletes repos locally on record, but not in payload" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      insert_pair(:github_repo, github_app_installation: installation)

      {:ok, %GithubAppInstallation{} = updated_installation} = Repos.process(installation |> Repo.preload(:github_repos))

      [repo_1, repo_2] = updated_installation.github_repos
      %{"repositories" => [repo_1_payload, repo_2_payload]} = @installation_repositories

      attributes = [:github_id, :name, :github_account_id, :github_account_avatar_url, :github_account_login, :github_account_type]

      assert repo_1 |> Map.take(attributes) == repo_1_payload |> GithubRepoAdapter.from_api
      assert repo_2 |> Map.take(attributes) == repo_2_payload |> GithubRepoAdapter.from_api

      assert GithubRepo |> Repo.aggregate(:count, :id) == 2
    end

    @tag bypass: %{
      "/installation/repositories" => {200, @installation_repositories},
      "/installations/#{@app_github_id}/access_tokens" => {200, @access_token_create_response}
    }
    test "updates repos locally on record and also in payload" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      %{"repositories" => [repo_1_payload, repo_2_payload]} = @installation_repositories
      insert(:github_repo, repo_1_payload |> GithubRepoAdapter.from_api |> Map.put(:github_app_installation, installation))
      insert(:github_repo, repo_2_payload |> GithubRepoAdapter.from_api |> Map.put(:github_app_installation, installation))

      {:ok, %GithubAppInstallation{} = updated_installation} = Repos.process(installation |> Repo.preload(:github_repos))
      [repo_1, repo_2] = updated_installation.github_repos

      attributes = [:github_id, :name, :github_account_id, :github_account_avatar_url, :github_account_login, :github_account_type]

      assert repo_1 |> Map.take(attributes) == repo_1_payload |> GithubRepoAdapter.from_api
      assert repo_2 |> Map.take(attributes) == repo_2_payload |> GithubRepoAdapter.from_api

      assert GithubRepo |> Repo.aggregate(:count, :id) == 2
    end

    @tag bypass: %{
      "/installation/repositories" => {403, @forbidden},
      "/installations/#{@app_github_id}/access_tokens" => {200, @access_token_create_response}
    }
    test "returns installation untouched if api error" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")
      {:error, %CodeCorps.GitHub.APIError{}} = Repos.process(installation)
      assert Repo.one(GithubAppInstallation).state == "initiated_on_code_corps"
    end

    @tag bypass: %{
      "/installation/repositories" => {200, @installation_repositories |> Map.put("repositories", ["foo"])},
      "/installations/#{@app_github_id}/access_tokens" => {200, @access_token_create_response}
    }
    test "returns installation untouched if payload incorrect" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")
      {:error, :invalid_repo_payload} = Repos.process(installation)
      assert Repo.one(GithubAppInstallation).state == "initiated_on_code_corps"
    end
  end
end

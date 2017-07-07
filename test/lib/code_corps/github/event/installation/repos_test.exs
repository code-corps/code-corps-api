defmodule CodeCorps.GitHub.Event.Installation.ReposTest do
  @moduledoc false

  use CodeCorps.DbAccessCase
  use CodeCorps.GitHubCase

  import CodeCorps.Factories
  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubAppInstallation,
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

  @tag bypass: %{
    "/installation/repositories" => {200, @installation_repositories},
    "/installations/#{@app_github_id}/access_tokens" => {200, @access_token_create_response}
  }
  describe "process/1" do
    test "creates repos, returns installation with repos and state set to processed" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      {:ok, %GithubAppInstallation{} = updated_installation} = Repos.process(installation)

      assert updated_installation.state == "processed"
      assert updated_installation.github_repos |> Enum.count == 2

      [repo_1, repo_2] = updated_installation.github_repos
      %{"repositories" => [repo_1_payload, repo_2_payload]} = @installation_repositories

      attributes = [:github_id, :name, :github_account_id, :github_account_avatar_url, :github_account_login, :github_account_type]

      assert repo_1 |> Map.take(attributes) == repo_1_payload |> GithubRepoAdapter.from_api
      assert repo_2 |> Map.take(attributes) == repo_2_payload |> GithubRepoAdapter.from_api
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

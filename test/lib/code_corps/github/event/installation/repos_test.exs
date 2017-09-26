defmodule CodeCorps.GitHub.Event.Installation.ReposTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GithubAppInstallation,
    GithubRepo,
    GitHub.Event.Installation.Repos,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.GithubRepo, as: GithubRepoAdapter

  defmodule BadRepoRequest do
    def request(:get, "https://api.github.com/installation/repositories", _, _, _) do
      body = load_endpoint_fixture("forbidden")
      {:error, CodeCorps.GitHub.APIError.new({404, %{"message" => body}})}
    end
    def request(method, endpoint, headers, body, options) do
      CodeCorps.GitHub.SuccessAPI.request(method, endpoint, headers, body, options)
    end
  end

  defmodule InvalidRepoRequest do
    def request(:get, "https://api.github.com/installation/repositories", _, _, _) do
      payload =
        "installation_repositories"
        |> load_endpoint_fixture
        |> Map.put("repositories", [%{}])
      {:ok, payload}
    end
    def request(method, endpoint, headers, body, options) do
      CodeCorps.GitHub.SuccessAPI.request(method, endpoint, headers, body, options)
    end
  end

  # from fixture
  @installation_repositories load_endpoint_fixture("installation_repositories")
  @app_github_id 2

  describe "process_async/1" do
    test "syncs repos by performing a diff using payload as master list, asynchronously" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      %{"repositories" => [matched_repo_payload, new_repo_payload]} = @installation_repositories
      matched_repo_attrs = matched_repo_payload |> GithubRepoAdapter.from_api
      new_repo_attrs = new_repo_payload |> GithubRepoAdapter.from_api

      unmatched_repo = insert(:github_repo, github_app_installation: installation)
      _matched_repo = insert(:github_repo, matched_repo_attrs |> Map.put(:github_app_installation, installation))

      {:ok, {%GithubAppInstallation{state: intermediate_state}, task}} =
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

    test "returns installation as errored if api error" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      with_mock_api(BadRepoRequest) do
        {:error, %GithubAppInstallation{state: state}, %CodeCorps.GitHub.APIError{}} = Repos.process(installation)
      end

      assert state == "errored"
    end

    test "returns installation as errored if error creating repos" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      with_mock_api(InvalidRepoRequest) do
        {:error, %GithubAppInstallation{state: state}, _changesets}
          = installation |> Repo.preload(:github_repos) |> Repos.process()
      end

      assert state == "errored"
    end
  end
end

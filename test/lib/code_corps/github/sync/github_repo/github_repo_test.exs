defmodule CodeCorps.GitHub.Sync.GithubRepoTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GithubAppInstallation,
    GithubRepo,
    GitHub.Sync,
    Repo
  }

  # from fixture
  @installation_repositories load_endpoint_fixture("installation_repositories")
  @app_github_id 2

  describe "sync_installation/1" do
    test "syncs repos by performing a diff using payload as master list" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      %{
        "repositories" => [
          %{"id" => matched_repo_github_id},
          %{"id" => new_repo_github_id}
        ]
      } = @installation_repositories

      unmatched_repo = insert(:github_repo, github_app_installation: installation)
      _matched_repo = insert(:github_repo, github_app_installation: installation, github_id: matched_repo_github_id)

      {:ok, {synced_repos, deleted_repos}} =
        installation |> Sync.GithubRepo.sync_installation()

      assert synced_repos |> Enum.count == 2
      assert deleted_repos |> Enum.count == 1

      %GithubAppInstallation{state: end_state} =
        Repo.get(GithubAppInstallation, installation.id)

      assert end_state == "processed"

      # unmatched repo was on record, but not in the payload, so it got deleted
      refute Repo.get(GithubRepo, unmatched_repo.id)
      # matched repo was both on record and in the payload, so it got updated
      assert Repo.get_by(GithubRepo, github_id: matched_repo_github_id)
      # new_repo was not on record, but was in the payload, so it got created
      assert Repo.get_by(GithubRepo, github_id: new_repo_github_id)

      # ensure no other repos have been created
      assert GithubRepo |> Repo.aggregate(:count, :id) == 2
    end

    defmodule InvalidRepoRequest do
      def request(:get, "https://api.github.com/installation/repositories", _, _, _) do
        good_payload = "installation_repositories" |> load_endpoint_fixture()
        %{"repositories" => [repo_1, repo_2]} = good_payload

        bad_repo_1 = repo_1 |> Map.put("name", nil)

        bad_payload =
          good_payload |> Map.put("repositories", [bad_repo_1, repo_2])

        {:ok, body} = bad_payload |> Poison.encode

        {:ok, %HTTPoison.Response{status_code: 200, body: body}}
      end
      def request(method, endpoint, body, headers, options) do
        CodeCorps.GitHub.SuccessAPI.request(method, endpoint, body, headers, options)
      end
    end

    test "fails if there are repo validation erorrs" do
      installation = insert(:github_app_installation, github_id: @app_github_id, state: "initiated_on_code_corps")

      with_mock_api(InvalidRepoRequest) do
        {:error, {:sync, {repos, changesets}}} =
          installation |> Sync.GithubRepo.sync_installation()

        assert repos |> Enum.count == 1
        assert changesets |> Enum.count == 1
      end
    end
  end
end

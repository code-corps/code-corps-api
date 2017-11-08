defmodule CodeCorps.GitHub.Event.InstallationRepositoriesTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GithubRepo,
    GitHub.Event.InstallationRepositories,
    ProjectGithubRepo,
    Repo
  }

  describe "handle/1" do
    @payload load_event_fixture("installation_repositories_added")

    test "marks event as errored if invalid action" do
      payload = @payload |> Map.put("action", "foo")
      assert {:error, :unexpected_action} == InstallationRepositories.handle(payload)
    end

    test "marks event as errored if invalid payload" do
      payload = @payload |> Map.delete("action")
      assert {:error, :unexpected_payload} ==
        InstallationRepositories.handle(payload)
    end
  end

  describe "handle/1 for InstallationRepositories::added" do
    @payload load_event_fixture("installation_repositories_added")

    test "creates repos" do
      %{
        "installation" => %{
          "account" => %{
            "avatar_url" => installation_account_avatar_url,
            "id" => installation_account_id,
            "login" => installation_account_login,
            "type" => installation_account_type
          },
          "id" => installation_github_id
        },
        "repositories_added" => [repo_1_payload, repo_2_payload]
      } = @payload

      %{id: installation_id} = insert(:github_app_installation, github_account_avatar_url: installation_account_avatar_url, github_account_id: installation_account_id, github_account_login: installation_account_login, github_account_type: installation_account_type, github_id: installation_github_id)

      {:ok, [%GithubRepo{}, %GithubRepo{}]} = InstallationRepositories.handle(@payload)

      github_repo_1 = Repo.get_by(GithubRepo, github_id: repo_1_payload["id"])
      assert github_repo_1
      assert github_repo_1.name == repo_1_payload["name"]
      assert github_repo_1.github_account_avatar_url == installation_account_avatar_url
      assert github_repo_1.github_account_id == installation_account_id
      assert github_repo_1.github_account_login == installation_account_login
      assert github_repo_1.github_account_type == installation_account_type
      assert github_repo_1.github_app_installation_id == installation_id

      github_repo_2 = Repo.get_by(GithubRepo, github_id: repo_2_payload["id"])
      assert github_repo_2
      assert github_repo_2.name == repo_2_payload["name"]
      assert github_repo_2.github_account_avatar_url == installation_account_avatar_url
      assert github_repo_2.github_account_id == installation_account_id
      assert github_repo_2.github_account_login == installation_account_login
      assert github_repo_2.github_account_type == installation_account_type
      assert github_repo_2.github_app_installation_id == installation_id
    end

    test "skips creating existing repos" do
      %{
        "installation" => %{
          "account" => %{
            "avatar_url" => installation_account_avatar_url,
            "id" => installation_account_id,
            "login" => installation_account_login,
            "type" => installation_account_type
          },
          "id" => installation_github_id
        },
        "repositories_added" => [repo_1_payload, repo_2_payload]
      } = @payload

      installation = insert(:github_app_installation, github_account_avatar_url: installation_account_avatar_url, github_account_id: installation_account_id, github_account_login: installation_account_login, github_account_type: installation_account_type, github_id: installation_github_id)
      preinserted_repo = insert(:github_repo, github_app_installation: installation, github_id: repo_1_payload["id"])

      {:ok, [%GithubRepo{}, %GithubRepo{}]} = InstallationRepositories.handle(@payload)

      github_repo_1 = Repo.get_by(GithubRepo, github_id: repo_1_payload["id"])
      assert github_repo_1.id == preinserted_repo.id

      github_repo_2 = Repo.get_by(GithubRepo, github_id: repo_2_payload["id"])
      assert github_repo_2
      assert github_repo_2.name == repo_2_payload["name"]
      assert github_repo_2.github_account_avatar_url == installation_account_avatar_url
      assert github_repo_2.github_account_id == installation_account_id
      assert github_repo_2.github_account_login == installation_account_login
      assert github_repo_2.github_account_type == installation_account_type
      assert github_repo_2.github_app_installation_id == installation.id

      assert Repo.aggregate(GithubRepo, :count, :id) == 2
    end

    test "marks event as errored if invalid instalation payload" do
      assert {:error, :unexpected_payload} == InstallationRepositories.handle(@payload |> Map.put("installation", "foo"))
    end

    test "marks event as errored if invalid repo payload" do
      insert(:github_app_installation, github_id: @payload["installation"]["id"])
      assert {:error, :unexpected_payload} == InstallationRepositories.handle(@payload |> Map.put("repositories_added", ["foo"]))
    end

    test "marks event as errored if no installation" do
      assert {:error, :unmatched_installation} == InstallationRepositories.handle(@payload)
    end
  end

  describe "handle/1 for InstallationRepositories::removed" do
    @payload load_event_fixture("installation_repositories_removed")

    test "deletes github repos and associated project github repos" do
      %{
        "installation" => %{"id" => installation_github_id},
        "repositories_removed" => [repo_1_payload, repo_2_payload]
      } = @payload

      %{project: project} = installation = insert(:github_app_installation, github_id: installation_github_id)
      github_repo_1 = insert(:github_repo, github_app_installation: installation, github_id: repo_1_payload["id"])
      insert(:project_github_repo, project: project, github_repo: github_repo_1)
      insert(:github_repo, github_app_installation: installation, github_id: repo_2_payload["id"])

      {:ok, [%GithubRepo{}, %GithubRepo{}]} = InstallationRepositories.handle(@payload)

      assert Repo.aggregate(GithubRepo, :count, :id) == 0
      assert Repo.aggregate(ProjectGithubRepo, :count, :id) == 0
    end

    test "skips deleting if nothing to delete" do
      %{
        "installation" => %{"id" => installation_github_id},
        "repositories_removed" => [repo_1_payload, _repo_2_payload]
      } = @payload

      %{project: project} = installation = insert(:github_app_installation, github_id: installation_github_id)
      github_repo_1 = insert(:github_repo, github_app_installation: installation, github_id: repo_1_payload["id"])
      insert(:project_github_repo, project: project, github_repo: github_repo_1)

      {:ok, [%GithubRepo{}]} = InstallationRepositories.handle(@payload)

      assert Repo.aggregate(GithubRepo, :count, :id) == 0
      assert Repo.aggregate(ProjectGithubRepo, :count, :id) == 0
    end

    test "marks event as errored if invalid instalation payload" do
      payload = @payload |> Map.put("installation", "foo")
      assert {:error, :unexpected_payload} ==
        InstallationRepositories.handle(payload)
    end

    test "marks event as errored if invalid repo payload" do
      insert(:github_app_installation, github_id: @payload["installation"]["id"])
      payload = @payload |> Map.put("repositories_removed", ["foo"])
      assert {:error, :unexpected_payload} ==
        InstallationRepositories.handle(payload)
    end

    test "marks event as errored if no installation" do
      assert {:error, :unmatched_installation} == InstallationRepositories.handle(@payload)
    end
  end
end

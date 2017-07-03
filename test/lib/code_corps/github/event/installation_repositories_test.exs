defmodule CodeCorps.GitHub.Event.InstallationRepositoriesTest do
  @moduledoc false

  use CodeCorps.DbAccessCase
  use CodeCorps.GitHubCase

  import CodeCorps.Factories
  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubEvent,
    GithubRepo,
    GitHub.Event.InstallationRepositories,
    ProjectGithubRepo,
    Repo
  }

  describe "handle/2" do
    test "marks event as errored if invalid action" do
      payload = %{}
      event = insert(:github_event, action: "foo", type: "installation_repositories")
      assert InstallationRepositories.handle(event, payload)

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "errored"
    end

    test "marks event as errored if invalid payload" do
      payload = %{}
      event = insert(:github_event, action: "added", type: "installation_repositories")
      assert InstallationRepositories.handle(event, payload)

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "errored"
    end
  end

  describe "handle/2 for InstallationRepositories::added" do
    @payload load_event_fixture("installation_repositories_added")

    test "creates repos" do
      %{
        "installation" => %{"id" => installation_github_id},
        "repositories_added" => [repo_1_payload, repo_2_payload]
      } = @payload

      %{id: installation_id} = insert(:github_app_installation, github_id: installation_github_id)

      event = insert(:github_event, action: "added", type: "installation_repositories")
      assert InstallationRepositories.handle(event, @payload)

      github_repo_1 = Repo.get_by(GithubRepo, github_id: repo_1_payload["id"])
      assert github_repo_1
      assert github_repo_1.name == repo_1_payload["name"]
      assert github_repo_1.github_app_installation_id == installation_id

      github_repo_2 = Repo.get_by(GithubRepo, github_id: repo_2_payload["id"])
      assert github_repo_2
      assert github_repo_2.name == repo_2_payload["name"]
      assert github_repo_2.github_app_installation_id == installation_id

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"
    end

    test "skips creating existing repos" do
      %{
        "installation" => %{"id" => installation_github_id},
        "repositories_added" => [repo_1_payload, repo_2_payload]
      } = @payload

      installation = insert(:github_app_installation, github_id: installation_github_id)
      preinserted_repo = insert(:github_repo, github_app_installation: installation, github_id: repo_1_payload["id"])

      event = insert(:github_event, action: "added", type: "installation_repositories")
      assert InstallationRepositories.handle(event, @payload)

      github_repo_1 = Repo.get_by(GithubRepo, github_id: repo_1_payload["id"])
      assert github_repo_1.id == preinserted_repo.id

      github_repo_2 = Repo.get_by(GithubRepo, github_id: repo_2_payload["id"])
      assert github_repo_2
      assert github_repo_2.name == repo_2_payload["name"]
      assert github_repo_2.github_app_installation_id == installation.id

      assert Repo.aggregate(GithubRepo, :count, :id) == 2

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"
    end

    test "marks event as errored if invalid instalation payload" do
      event = insert(:github_event, action: "added", type: "installation_repositories")
      assert InstallationRepositories.handle(event, @payload |> Map.put("installation", "foo"))

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "errored"
    end

    test "marks event as errored if invalid repo payload" do
      event = insert(:github_event, action: "added", type: "installation_repositories")
      assert InstallationRepositories.handle(event, @payload |> Map.put("repositories_added", ["foo"]))

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "errored"
    end

    test "marks event as errored if no installation" do
      event = insert(:github_event, action: "added", type: "installation_repositories")
      assert InstallationRepositories.handle(event, @payload)

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "errored"
    end
  end

  describe "handle/2 for InstallationRepositories::removed" do
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

      event = insert(:github_event, action: "removed", type: "installation_repositories")
      assert InstallationRepositories.handle(event, @payload)

      assert Repo.aggregate(GithubRepo, :count, :id) == 0
      assert Repo.aggregate(ProjectGithubRepo, :count, :id) == 0

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"
    end

    test "skips deleting if nothing to delete" do
      %{
        "installation" => %{"id" => installation_github_id},
        "repositories_removed" => [repo_1_payload, _repo_2_payload]
      } = @payload

      %{project: project} = installation = insert(:github_app_installation, github_id: installation_github_id)
      github_repo_1 = insert(:github_repo, github_app_installation: installation, github_id: repo_1_payload["id"])
      insert(:project_github_repo, project: project, github_repo: github_repo_1)

      event = insert(:github_event, action: "removed", type: "installation_repositories")
      assert InstallationRepositories.handle(event, @payload)

      assert Repo.aggregate(GithubRepo, :count, :id) == 0
      assert Repo.aggregate(ProjectGithubRepo, :count, :id) == 0

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"
    end

    test "marks event as errored if invalid instalation payload" do
      event = insert(:github_event, action: "removed", type: "installation_repositories")
      assert InstallationRepositories.handle(event, @payload |> Map.put("installation", "foo"))

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "errored"
    end

    test "marks event as errored if invalid repo payload" do
      event = insert(:github_event, action: "removed", type: "installation_repositories")
      assert InstallationRepositories.handle(event, @payload |> Map.put("repositories_removed", ["foo"]))

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "errored"
    end

    test "marks event as errored if no installation" do
      event = insert(:github_event, action: "added", type: "installation_repositories")
      assert InstallationRepositories.handle(event, @payload)

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "errored"
    end
  end
end

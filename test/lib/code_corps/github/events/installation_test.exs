defmodule CodeCorps.GitHub.Events.InstallationTest do
  @moduledoc false

  use CodeCorps.DbAccessCase
  use CodeCorps.GitHubCase

  import CodeCorps.Factories
  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubAppInstallation,
    GithubEvent,
    GithubRepo,
    GitHub.Events.Installation,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.GithubRepo, as: GithubRepoAdapter

  @access_token "v1.1f699f1069f60xxx"
  @expires_at Timex.now() |> Timex.shift(hours: 1) |> DateTime.to_iso8601()
  @access_token_create_response %{"token" => @access_token, "expires_at" => @expires_at}

  @installation_created load_event_fixture("installation_created")
  @installation_repositories load_endpoint_fixture("installation_repositories")

  describe "handle/2" do
    test "creates installation for unmatched user if no user" do
      payload = @installation_created
      event = insert(:github_event, action: "created", type: "installation")

      assert Installation.handle(event, payload)

      github_app_installation = Repo.one(GithubAppInstallation)
      assert github_app_installation.github_id == (payload |> get_in(["installation", "id"]))
      assert github_app_installation.state == "unmatched_user"
      refute github_app_installation.user_id
      assert github_app_installation.installed == true

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"
    end

    test "creates installation initiated_on_github if user matched but installation unmatched" do
      %{"sender" => %{"id" => user_github_id}} = payload = @installation_created
      event = insert(:github_event, action: "created", type: "installation")

      user = insert(:user, github_id: user_github_id)

      assert Installation.handle(event, payload)

      github_app_installation = Repo.one(GithubAppInstallation)
      assert github_app_installation.github_id == (payload |> get_in(["installation", "id"]))
      assert github_app_installation.state == "initiated_on_github"
      assert github_app_installation.user_id == user.id
      assert github_app_installation.installed == true

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"
    end

    @tag bypass: %{"/installation/repositories" => {200, @installation_repositories},
    "/installations/2/access_tokens" => {200, @access_token_create_response}}
    test "updates installation, creates repos, if both user and installation matched" do
      %{"sender" => %{"id" => user_github_id}, "installation" => %{"id" => installation_github_id}} = payload = @installation_created
      event = insert(:github_event, action: "created", type: "installation")

      user = insert(:user, github_id: user_github_id)
      github_app_installation = insert(:github_app_installation, github_id: installation_github_id, user: user)

      assert Installation.handle(event, payload)

      updated_github_app_installation = Repo.one(GithubAppInstallation)
      assert updated_github_app_installation.github_id == (payload |> get_in(["installation", "id"]))
      assert updated_github_app_installation.state == "processed"
      assert updated_github_app_installation.user_id == user.id
      assert updated_github_app_installation.github_id == installation_github_id
      assert updated_github_app_installation.id == github_app_installation.id
      assert updated_github_app_installation.installed == true

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"

      [repo_fixture] = @installation_repositories |> Map.get("repositories")

      repo = Repo.get_by(GithubRepo, GithubRepoAdapter.from_api(repo_fixture))
      assert repo.github_app_installation_id == updated_github_app_installation.id
    end
  end
end

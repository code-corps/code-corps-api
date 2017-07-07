defmodule CodeCorps.GitHub.Event.InstallationTest do
  @moduledoc false

  use CodeCorps.DbAccessCase
  use CodeCorps.GitHubCase

  import CodeCorps.Factories
  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubAppInstallation,
    GithubEvent,
    GithubRepo,
    GitHub.Event.Installation,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.GithubRepo, as: GithubRepoAdapter

  @access_token "v1.1f699f1069f60xxx"
  @expires_at Timex.now() |> Timex.shift(hours: 1) |> DateTime.to_iso8601()
  @access_token_create_response %{"token" => @access_token, "expires_at" => @expires_at}

  @installation_created load_event_fixture("installation_created")
  @installation_repositories load_endpoint_fixture("installation_repositories")
  @forbidden load_endpoint_fixture("forbidden")

  describe "handle/2" do
    test "marks event as errored if payload is wrong" do
      event = insert(:github_event, action: "created", type: "installation")
      Installation.handle(event, %{})
      assert Repo.one(GithubEvent).status == "errored"
    end

    test "marks event as errored if action of the event is wrong" do
      event = insert(:github_event, action: "foo", type: "installation")
      Installation.handle(event, @installation_created)
      assert Repo.one(GithubEvent).status == "errored"
    end

    test "marks event as errored if user payload is wrong" do
      event = insert(:github_event, action: "created", type: "installation")
      Installation.handle(event, @installation_created |> Map.put("sender", "foo"))
      assert Repo.one(GithubEvent).status == "errored"
    end

    test "marks event as errored if installation payload is wrong" do
      event = insert(:github_event, action: "created", type: "installation")
      Installation.handle(event, @installation_created |> Map.put("installation", "foo"))
      assert Repo.one(GithubEvent).status == "errored"
    end
  end

  describe "handle/2 for Installation::created" do
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

    @tag bypass: %{
      "/installation/repositories" => {200, @installation_repositories},
      "/installations/#{@installation_created["installation"]["id"]}/access_tokens" => {200, @access_token_create_response}
    }
    test "updates installation, creates repos, if both user and installation matched" do
      %{"sender" => %{"id" => user_github_id}, "installation" => %{"id" => installation_github_id}} = payload = @installation_created
      event = insert(:github_event, action: "created", type: "installation")

      user = insert(:user, github_id: user_github_id)
      insert(
        :github_app_installation,
        user: user,
        access_token_expires_at: Timex.now |> Timex.shift(days: 1)
      )

      assert Installation.handle(event, payload)

      updated_github_app_installation = Repo.one(GithubAppInstallation)
      assert updated_github_app_installation.state == "processed"
      assert updated_github_app_installation.user_id == user.id
      assert updated_github_app_installation.github_id == installation_github_id
      assert updated_github_app_installation.installed == true

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"

      %{"repositories" => [repo_fixture_1, repo_fixture_2]} = @installation_repositories

      repo_1 = Repo.get_by(GithubRepo, GithubRepoAdapter.from_api(repo_fixture_1))
      assert repo_1.github_app_installation_id == updated_github_app_installation.id

      repo_2 = Repo.get_by(GithubRepo, GithubRepoAdapter.from_api(repo_fixture_2))
      assert repo_2.github_app_installation_id == updated_github_app_installation.id
    end

    test "updates installation if there is an installation, but no user" do
      %{"installation" => %{"id" => installation_github_id}, "sender" => %{"id" => sender_github_id}} = payload = @installation_created
      event = insert(:github_event, action: "created", type: "installation")
      insert(:github_app_installation, github_id: installation_github_id)
      Installation.handle(event, payload)

      installation =  Repo.one(GithubAppInstallation)
      assert installation
      assert installation.state == "unmatched_user"
      assert installation.sender_github_id == sender_github_id

      assert Repo.one(GithubEvent).status == "processed"
    end

    @tag bypass: %{
      "/installation/repositories" => {200, @installation_repositories |> Map.put("repositories", ["foo"])},
      "/installations/2/access_tokens" => {200, @access_token_create_response}
    }
    test "marks event as errored if any of the repo payloads are wrong" do
      %{"sender" => %{"id" => user_github_id}} = payload = @installation_created
      event = insert(:github_event, action: "created", type: "installation")

      user = insert(:user, github_id: user_github_id)
      insert(:github_app_installation, user: user)

      assert Installation.handle(event, payload)
    end

    @tag bypass: %{
      "/installation/repositories" => {403, @forbidden},
      "/installations/#{@installation_created["installation"]["id"]}/access_tokens" => {200, @access_token_create_response}
    }
    test "marks event as errored if there is an api error" do
      %{"sender" => %{"id" => user_github_id}} = payload = @installation_created
      event = insert(:github_event, action: "created", type: "installation")

      user = insert(:user, github_id: user_github_id)
      insert(:github_app_installation, user: user)

      assert Installation.handle(event, payload)
    end
  end
end

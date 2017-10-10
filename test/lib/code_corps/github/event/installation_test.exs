defmodule CodeCorps.GitHub.Event.InstallationTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GithubAppInstallation,
    GithubRepo,
    GitHub.Event.Installation,
    Repo
  }

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

  @installation_created load_event_fixture("installation_created")
  @bad_action_payload @installation_created |> Map.put("action", "foo")
  @bad_sender_payload @installation_created |> Map.put("sender", "foo")
  @bad_installation_payload @installation_created |> Map.put("installation", "foo")

  describe "handle/2" do
    test "returns error if action of the event is wrong" do
      event = build(:github_event, action: "foo", type: "installation")
      assert {:error, :unexpected_action} ==
        Installation.handle(event, @bad_action_payload)
    end

    test "returns error if payload is wrong" do
      event = build(:github_event, action: "created", type: "installation")
      assert {:error, :unexpected_payload} == Installation.handle(event, %{})
    end

    test "returns error if user payload is wrong" do
      event = build(:github_event, action: "created", type: "installation")
      assert {:error, :unexpected_payload} ==
        Installation.handle(event, @bad_sender_payload)
    end

    test "returns error if installation payload is wrong" do
      event = build(:github_event, action: "created", type: "installation")
      assert {:error, :unexpected_payload} ==
        Installation.handle(event, @bad_installation_payload)
    end

    test "returns installation as errored if api error" do
      event = build(:github_event, action: "created", type: "installation")

      with_mock_api(BadRepoRequest) do
        assert {:error, :github_api_error_on_syncing_repos}
          = Installation.handle(event, @installation_created)
      end
    end

    test "returns installation as errored if error creating repos" do
      event = build(:github_event, action: "created", type: "installation")

      with_mock_api(InvalidRepoRequest) do
        assert {:error, :validation_error_on_syncing_existing_repos} ==
          Installation.handle(event, @installation_created)
      end
    end
  end

  describe "handle/2 for Installation::created" do
    test "creates installation for unmatched user if no user, syncs repos" do
      payload = %{"installation" => %{"id" => installation_github_id}} = @installation_created
      event = build(:github_event, action: "created", type: "installation")

      {:ok, %GithubAppInstallation{} = installation}
        = Installation.handle(event, payload)

      assert installation.github_id == installation_github_id
      assert installation.origin == "github"
      assert installation.state == "processed"
      refute installation.user_id
      assert installation.installed == true
      assert Repo.aggregate(GithubRepo, :count, :id) == 2
    end

    test "creates installation if user matched but installation unmatched, syncs repos" do
      %{"sender" => %{"id" => user_github_id}} = payload = @installation_created
      event = build(:github_event, action: "created", type: "installation")

      user = insert(:user, github_id: user_github_id)

      {:ok, %GithubAppInstallation{} = installation}
        = Installation.handle(event, payload)

      assert installation.github_id == (payload |> get_in(["installation", "id"]))
      assert installation.origin == "github"
      assert installation.state == "processed"
      assert installation.user_id == user.id
      assert installation.installed == true

      assert Repo.aggregate(GithubRepo, :count, :id) == 2
    end

    test "updates installation, if both user and installation matched, syncs repos" do
      %{"sender" => %{"id" => user_github_id}, "installation" => %{"id" => installation_github_id}} = payload = @installation_created
      event = build(:github_event, action: "created", type: "installation")

      user = insert(:user, github_id: user_github_id)
      insert(
        :github_app_installation,
        user: user,
        access_token_expires_at: Timex.now |> Timex.shift(days: 1),
        github_id: nil
      )

      {:ok, %GithubAppInstallation{} = installation}
        = Installation.handle(event, payload)

      assert installation.origin == "codecorps"
      assert installation.state == "processed"
      assert installation.user_id == user.id
      assert installation.github_id == installation_github_id
      assert installation.installed == true

      assert Repo.aggregate(GithubRepo, :count, :id) == 2
    end

    test "updates installation if there is an installation, but no user, syncs repos" do
      %{"installation" => %{"id" => installation_github_id}, "sender" => %{"id" => sender_github_id}} = payload = @installation_created
      insert(:github_app_installation, github_id: installation_github_id)
      event = build(:github_event, action: "created", type: "installation")

      {:ok, %GithubAppInstallation{} = installation}
        = Installation.handle(event, payload)

      assert installation.origin == "codecorps"
      assert installation.state == "processed"
      assert installation.sender_github_id == sender_github_id

      assert Repo.aggregate(GithubRepo, :count, :id) == 2
    end
  end
end

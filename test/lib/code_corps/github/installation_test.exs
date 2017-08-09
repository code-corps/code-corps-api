defmodule CodeCorps.GitHub.InstallationTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase
  use CodeCorps.GitHubCase

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubAppInstallation,
    GitHub.Installation
  }

  @access_token "v1.1f699f1069f60xxx"
  @installation_github_id 1
  @expires_at Timex.now() |> Timex.shift(hours: 1) |> DateTime.to_iso8601()
  @access_token_create_response %{"token" => @access_token, "expires_at" => @expires_at}

  @installation_repositories load_endpoint_fixture("installation_repositories")
  @installations_access_tokens load_endpoint_fixture("installations_access_tokens")

  @tag bypass: %{
    "/installation/repositories" => {200, @installation_repositories},
    "/installations/#{@installation_github_id}/access_tokens" => {200, @access_token_create_response}
  }
  describe "repositories/1" do
    test "makes a request to get the repositories for the authenticated installation" do
      installation = %GithubAppInstallation{github_id: @installation_github_id, access_token: @access_token, access_token_expires_at: @expires_at}

      assert Installation.repositories(installation) == {:ok, @installation_repositories |> Map.get("repositories")}
    end
  end

  describe "get_access_token/1" do
    test "returns current token if expires time has not passed" do
      expires_at =
        Timex.now()
        |> Timex.shift(hours: 1)

      installation = %GithubAppInstallation{access_token: @access_token, access_token_expires_at: expires_at}

      assert Installation.get_access_token(installation) == {:ok, @access_token}
    end

    @tag bypass: %{"/installations/#{@installation_github_id}/access_tokens" => {200, @installations_access_tokens}}
    test "returns a new token if expires time has passed" do
      expires_at =
        Timex.now()
        |> Timex.shift(hours: -1)

      installation = insert(:github_app_installation, github_id: @installation_github_id, access_token: "old-access-token", access_token_expires_at: expires_at)

      assert Installation.get_access_token(installation) == {:ok, @access_token}
    end

    @tag bypass: %{"/installations/#{@installation_github_id}/access_tokens" => {200, @installations_access_tokens}}
    test "returns a new token if token and expires time are nil" do
      installation = insert(:github_app_installation, github_id: @installation_github_id, access_token: nil, access_token_expires_at: nil)

      assert Installation.get_access_token(installation) == {:ok, @access_token}
    end
  end

  describe "token_expired?/1" do
    test "returns false for a future ISO8601 timestamp" do
      time = Timex.now() |> Timex.shift(hours: 1) |> DateTime.to_iso8601()
      refute Installation.token_expired?(time)
    end

    test "returns false for a current ISO8601 timestamp" do
      time = Timex.now() |> DateTime.to_iso8601()
      assert Installation.token_expired?(time)
    end

    test "returns true for a past ISO8601 timestamp" do
      time = Timex.now() |> Timex.shift(hours: -1) |> DateTime.to_iso8601()
      assert Installation.token_expired?(time)
    end

    test "returns true for a nil value" do
      assert Installation.token_expired?(nil)
    end
  end
end

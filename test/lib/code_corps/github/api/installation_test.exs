defmodule CodeCorps.GitHub.API.InstallationTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GithubAppInstallation,
    GitHub.API.Installation
  }

  @access_token "v1.1f699f1069f60xxx"
  @expires_at Timex.now() |> Timex.shift(hours: 1) |> DateTime.to_iso8601()

  @installation_repositories load_endpoint_fixture("installation_repositories")

  describe "repositories/1" do
    test "makes a request to get the repositories for the authenticated installation" do
      installation = %GithubAppInstallation{access_token: @access_token, access_token_expires_at: @expires_at}

      assert Installation.repositories(installation) == {:ok, @installation_repositories |> Map.get("repositories")}
    end

    defmodule PaginatedRepositoriesAPI do
      @url "https://api.github.com/installation/repositories"

      defp build_repo(id), do: %{github_id: id}

      def request(:head, @url, _, _, _) do
        next = '<#{@url}?page=2>; rel="next"'
        last = '<#{@url}?page=2>; rel="last"'

        headers = [{"Link", [next, last] |> Enum.join(", ")}]
        {:ok, %HTTPoison.Response{body: "", headers: headers, status_code: 200}}
      end
      def request(:get, @url, _, _, opts) do
        body = case opts[:params][:page] do
          1 -> %{"repositories" => 1..100 |> Enum.map(&build_repo/1)}
          2 -> %{"repositories" => 1..50 |> Enum.map(&build_repo/1)}
        end

        {:ok, %HTTPoison.Response{body: body |> Poison.encode!, status_code: 200}}
      end
      def request(method, url, body, headers, opts) do
        CodeCorps.GitHub.SuccessAPI.request(method, url, body, headers, opts)
      end
    end

    test "supports pagination" do
      installation = %GithubAppInstallation{access_token: @access_token, access_token_expires_at: @expires_at}

      with_mock_api(PaginatedRepositoriesAPI) do
        {:ok, issues} = installation |> Installation.repositories
      end

      assert issues |> Enum.count == 150
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

    test "returns a new token if expires time has passed" do
      expires_at =
        Timex.now()
        |> Timex.shift(hours: -1)

      installation = insert(
        :github_app_installation,
        access_token: "old-access-token", access_token_expires_at: expires_at,
        github_id: 1)

      assert Installation.get_access_token(installation) == {:ok, @access_token}
    end

    test "returns a new token if token and expires time are nil" do
      installation = insert(
        :github_app_installation,
        access_token: nil, access_token_expires_at: nil,
        github_id: 1)

      assert Installation.get_access_token(installation) == {:ok, @access_token}
    end
  end

  describe "token_expired?/1" do
    test "returns false for a future ISO8601 timestamp" do
      time = Timex.now() |> Timex.shift(days: 14) |> DateTime.to_iso8601()
      refute Installation.token_expired?(time)
    end

    test "returns false for a current ISO8601 timestamp" do
      time = Timex.now() |> DateTime.to_iso8601()
      assert Installation.token_expired?(time)
    end

    test "returns true for a past ISO8601 timestamp" do
      time = Timex.now() |> Timex.shift(days: -14) |> DateTime.to_iso8601()
      assert Installation.token_expired?(time)
    end

    test "returns true for a nil value" do
      assert Installation.token_expired?(nil)
    end
  end
end

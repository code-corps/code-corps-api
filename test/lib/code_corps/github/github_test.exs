defmodule CodeCorps.GitHubTest do
  @moduledoc false

  use CodeCorps.DbAccessCase
  import CodeCorps.GitHub.TestHelpers
  alias CodeCorps.GitHub

  defmodule BasicSuccessAPI do
    def request(method, url, headers, body, options) do
      send(self(), {method, url, headers, body, options})
      {:ok, "foo"}
    end
  end

  defmodule BasicErrorAPI do
    def request(method, url, headers, body, options) do
      send(self(), {method, url, headers, body, options})
      {:error, "bar"}
    end
  end

  describe "request/5" do
    test "properly calls api and returns a successful response" do
      with_mock_api(BasicSuccessAPI) do
        assert {:ok, "foo"} == GitHub.request(:get, "foo", %{}, %{}, [])
      end

      assert_received({
        :get,
        "https://api.github.com/foo",
        [{"Accept", "application/vnd.github.machine-man-preview+json"}],
        "{}",
        [:with_body]
      })
    end

    test "properly calls api and returns an error response" do
      with_mock_api(BasicErrorAPI) do
        assert {:error, "bar"} = GitHub.request(:get, "bar", %{}, %{}, [])
      end

      assert_received({
        :get,
        "https://api.github.com/bar",
        [{"Accept", "application/vnd.github.machine-man-preview+json"}],
        "{}",
        [:with_body]
      })
    end
  end

  describe "user_access_token_request/2" do
    test "properly calls api and returns a successful response" do
      with_mock_api(BasicSuccessAPI) do
        assert {:ok, "foo"} == GitHub.user_access_token_request("foo_code", "foo_state")
      end

      assert_received({
        :post,
        "https://github.com/login/oauth/access_token",
        [{"Accept", "application/json"}, {"Content-Type", "application/json"}],
        body_text,
        [:with_body]
      })

      body = body_text |> Poison.decode!
      assert body["state"] == "foo_state"
      assert body["code"] == "foo_code"
      assert body |> Map.has_key?("client_secret")
      assert body |> Map.has_key?("client_id")
    end

    test "properly calls api and returns an error response" do
      with_mock_api(BasicErrorAPI) do
        assert {:error, "bar"} == GitHub.user_access_token_request("foo_code", "foo_state")
      end

      assert_received({
        :post, "https://github.com/login/oauth/access_token",
        [{"Accept", "application/json"}, {"Content-Type", "application/json"}],
        body_text,
        [:with_body]
      })

      body = body_text |> Poison.decode!
      assert body["state"] == "foo_state"
      assert body["code"] == "foo_code"
      assert body |> Map.has_key?("client_secret")
      assert body |> Map.has_key?("client_id")
    end
  end

  describe "integration_request/5" do
    test "properly calls api and returns a successful response" do
      with_mock_api(BasicSuccessAPI) do
        assert {:ok, "foo"} == GitHub.integration_request(:get, "foo", %{}, %{}, [])
      end

      assert_received({
        :get,
        "https://api.github.com/foo",
        [{"Accept", "application/vnd.github.machine-man-preview+json"}, {"Authorization", "Bearer" <> _}],
        "{}",
        [:with_body]
      })
    end

    test "properly calls api and returns an error response" do
      with_mock_api(BasicErrorAPI) do
        assert {:error, "bar"} = GitHub.integration_request(:get, "bar", %{}, %{}, [])
      end

      assert_received({
        :get,
        "https://api.github.com/bar",
        [{"Accept", "application/vnd.github.machine-man-preview+json"}, {"Authorization", "Bearer" <> _}],
        "{}",
        [:with_body]
      })
    end
  end
end

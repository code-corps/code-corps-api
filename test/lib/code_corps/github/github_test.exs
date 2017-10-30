defmodule CodeCorps.GitHubTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub,
    GitHub.APIError
  }

  @response_body %{"foo" => "bar"}

  @error_body %{"message" => "bar"}
  @error_code 401
  @error APIError.new({@error_code, @error_body})

  defmodule BasicSuccessAPI do
    def request(method, url, body, headers, options) do
      send(self(), {method, url, body, headers, options})
      {:ok, body} = %{"foo" => "bar"} |> Poison.encode
      {:ok, %HTTPoison.Response{body: body, status_code: 200}}
    end
  end

  defmodule BasicErrorAPI do
    def request(method, url, body, headers, options) do
      send(self(), {method, url, body, headers, options})
      {:ok, body} = %{"message" => "bar"} |> Poison.encode
      {:ok, %HTTPoison.Response{body: body, status_code: 401}}
    end
  end

  describe "request/5" do
    test "properly calls api and returns a successful response" do
      with_mock_api(BasicSuccessAPI) do
        assert {:ok, @response_body} == GitHub.request(:get, "foo", %{}, %{}, [])
      end

      assert_received({
        :get,
        "https://api.github.com/foo",
        "{}",
        [{"Accept", "application/vnd.github.machine-man-preview+json"}],
        []
      })
    end

    test "properly calls api and returns an error response" do
      with_mock_api(BasicErrorAPI) do
        assert {:error, @error} = GitHub.request(:get, "bar", %{}, %{}, [])
      end

      assert_received({
        :get,
        "https://api.github.com/bar",
        "{}",
        [{"Accept", "application/vnd.github.machine-man-preview+json"}],
        []
      })
    end
  end

  describe "user_access_token_request/2" do
    test "properly calls api and returns a successful response" do
      with_mock_api(BasicSuccessAPI) do
        assert {:ok, @response_body} == GitHub.user_access_token_request("foo_code", "foo_state")
      end

      assert_received({
        :post,
        "https://github.com/login/oauth/access_token",
        body_text,
        [{"Accept", "application/json"}, {"Content-Type", "application/json"}],
        []
      })

      body = body_text |> Poison.decode!
      assert body["state"] == "foo_state"
      assert body["code"] == "foo_code"
      assert body |> Map.has_key?("client_secret")
      assert body |> Map.has_key?("client_id")
    end

    test "properly calls api and returns an error response" do
      with_mock_api(BasicErrorAPI) do
        assert {:error, @error} == GitHub.user_access_token_request("foo_code", "foo_state")
      end

      assert_received({
        :post, "https://github.com/login/oauth/access_token",
        body_text,
        [{"Accept", "application/json"}, {"Content-Type", "application/json"}],
        []
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
        assert {:ok, @response_body} == GitHub.integration_request(:get, "foo", %{}, %{}, [])
      end

      assert_received({
        :get,
        "https://api.github.com/foo",
        "{}",
        [{"Accept", "application/vnd.github.machine-man-preview+json"}, {"Authorization", "Bearer" <> _}],
        []
      })
    end

    test "properly calls api and returns an error response" do
      with_mock_api(BasicErrorAPI) do
        assert {:error, @error} = GitHub.integration_request(:get, "bar", %{}, %{}, [])
      end

      assert_received({
        :get,
        "https://api.github.com/bar",
        "{}",
        [{"Accept", "application/vnd.github.machine-man-preview+json"}, {"Authorization", "Bearer" <> _}],
        []
      })
    end
  end
end

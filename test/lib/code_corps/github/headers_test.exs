defmodule CodeCorps.GitHub.HeadersTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias CodeCorps.GitHub.Headers

  describe "access_token_request/0" do
    test "works" do
      assert Headers.access_token_request == [
        {"Accept", "application/json"},
        {"Content-Type", "application/json"}
      ]
    end
  end

  describe "integration_request/1" do
    test "returns defaults when provided a blank map" do
      headers = Headers.integration_request(%{})

      assert {"Accept", "application/vnd.github.machine-man-preview+json"} in headers
    end

    test "merges with provided map" do
      headers = Headers.integration_request(%{"foo" => "bar"})

      assert {"Accept", "application/vnd.github.machine-man-preview+json"} in headers
      assert {"foo", "bar"} in headers
    end

    test "prioritizes keys in provided map" do
      headers = Headers.integration_request(%{"foo" => "bar", "Accept" => "baz"})

      assert {"Accept", "baz"} in headers
      assert {"foo", "bar"} in headers
    end

    test "adds a jwt to the headers" do
      headers = Headers.integration_request(%{})

      assert headers |> Enum.find(fn {key, _value} -> key == "Authorization" end)
    end
  end

  describe "user_request/2" do
    test "returns defaults when provided a blank map" do
      headers = Headers.user_request(%{}, [])
      assert {"Accept", "application/vnd.github.machine-man-preview+json"} in headers
    end

    test "merges with provided map" do
      headers = Headers.user_request(%{"foo" => "bar"}, [])
      assert {"Accept", "application/vnd.github.machine-man-preview+json"} in headers
      assert {"foo", "bar"} in headers
    end

    test "prioritizes keys in provided map" do
      headers = Headers.user_request(%{"foo" => "bar", "Accept" => "baz"}, [])
      assert {"Accept", "baz"} in headers
      assert {"foo", "bar"} in headers
    end

    test "adds access token if key is present in opts and not nil" do
      headers = Headers.user_request(%{"foo" => "bar"}, [access_token: "foo_bar"])
      assert {"Accept", "application/vnd.github.machine-man-preview+json"} in headers
      assert {"foo", "bar"} in headers
      assert {"Authorization", "token foo_bar"} in headers
    end

    test "does not add access token if key is present in opts but is nil" do
      headers = Headers.user_request(%{"foo" => "bar"}, [access_token: nil])
      assert {"Accept", "application/vnd.github.machine-man-preview+json"} in headers
      assert {"foo", "bar"} in headers
      refute headers |> Enum.find(fn {key, _value} -> key == "Authorization" end)
    end
  end
end

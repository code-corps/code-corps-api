defmodule CodeCorps.GitHubTest do
  @moduledoc false

  use CodeCorps.ModelCase
  use CodeCorps.GitHubCase

  alias CodeCorps.GitHub

  describe "request/5" do
    @tag bypass: %{"/foo" => {200, %{"bar" => "baz"}}}
    test "handles a successful response" do
      {:ok, response} = GitHub.request(%{}, :get, "foo", %{}, [])
      assert response == %{"bar" => "baz"}
    end

    @tag bypass: %{"/foo" => {404, %{"bar" => "baz"}}}
    test "handles an error response" do
      {:error, response} = GitHub.request(%{}, :get, "foo", %{}, [])
      assert response == CodeCorps.GitHub.APIError.new({404, %{"message" => %{"bar" => "baz"} |> Poison.encode!}})
    end
  end

  describe "user_access_token_request/2" do
    @tag bypass: %{"/" => {200, %{"bar" => "baz"}}}
    test "handles a successful response" do
      {:ok, response} = GitHub.user_access_token_request("foo_code", "foo_state")
      assert response == %{"bar" => "baz"}
    end

    @tag bypass: %{"/" => {404, %{"bar" => "baz"}}}
    test "handles an error response" do
      {:error, response} = GitHub.user_access_token_request("foo_code", "foo_state")
      assert response == CodeCorps.GitHub.APIError.new({404, %{"message" => %{"bar" => "baz"} |> Poison.encode!}})
    end
  end

  describe "authenticated_integration_request/5" do
    @tag bypass: %{"/foo" => {200, %{"bar" => "baz"}}}
    test "handles a successful response" do
      {:ok, response} = GitHub.authenticated_integration_request(%{}, :get, "foo", %{}, [])
      assert response == %{"bar" => "baz"}
    end

    @tag bypass: %{"/foo" => {404, %{"bar" => "baz"}}}
    test "handles an error response" do
      {:error, response} = GitHub.authenticated_integration_request(%{}, :get, "foo", %{}, [])
      assert response == CodeCorps.GitHub.APIError.new({404, %{"message" => %{"bar" => "baz"} |> Poison.encode!}})
    end
  end
end

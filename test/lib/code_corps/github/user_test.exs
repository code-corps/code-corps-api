defmodule CodeCorps.GitHub.UserTest do
  @moduledoc false

  use CodeCorps.{GitHubCase}

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{GitHub, User}

  @forbidden load_endpoint_fixture("forbidden")

  describe "me/2" do
    @payload load_endpoint_fixture("me")

    @tag bypass: %{"/user" => {200, @payload}}
    test "retrieves current user" do
      assert GitHub.User.me("foo") == {:ok, %GitHub.User{
        avatar_url: @payload["avatar_url"],
        email: @payload["email"],
        id: @payload["id"],
        login: @payload["login"]
      }}
    end

    @tag bypass: %{"/user" => {403, @forbidden}}
    test "returns error if there is an API issue" do
      {:error, %CodeCorps.GitHub.APIError{message: message, status_code: 403}}
        = GitHub.User.me("foo")

      assert message
    end
  end

  describe "installations/2" do
    @payload load_endpoint_fixture("user_installations")

    @tag bypass: %{"/user/installations" => {200, @payload}}
    test "retrieves list of installations" do
      user = %User{github_auth_token: "foo"}

      assert GitHub.User.installations(user) ==
        {:ok, @payload |> Map.get("installations")}
    end

    @tag bypass: %{"/user/installations" => {403, @forbidden}}
    test "returns error if there was an API issue" do
      user = %User{github_auth_token: "foo"}

      {:error, %CodeCorps.GitHub.APIError{message: message, status_code: 403}}
        = GitHub.User.installations(user)

      assert message
    end
  end
end

defmodule CodeCorps.GitHub.UserTest do
  @moduledoc false

  use CodeCorps.ModelCase
  use CodeCorps.GitHubCase

  alias CodeCorps.{GitHub, User}

  @user_data %{
    "avatar_url" => "foo_url",
    "email" => "foo_email",
    "id" => 123,
    "login" => "foo_login"
  }

  @token_data %{"access_token" => "foo_auth_token"}

  describe "connect/2" do
    @tag bypass: %{"/user" => {200, @user_data}, "/" => {200, @token_data}}
    test "posts to github, updates user if reply is ok, returns updated user" do
      user = insert(:user)

      {:ok, %User{} = returned_user} = GitHub.User.connect(user, "foo_code", "foo_state")

      assert returned_user.id == user.id
      assert returned_user.github_auth_token == "foo_auth_token"
      assert returned_user.github_avatar_url == "foo_url"
      assert returned_user.email == "foo_email"
      assert returned_user.github_id == 123
      assert returned_user.github_username == "foo_login"
    end

    @error_data %{"error" => "Not Found"}

    @tag bypass: %{"/" => {404, @error_data}}
    test "posts to github, returns error if reply is not ok" do
      user = insert(:user)
      error = GitHub.APIError.new({404, %{"message" => "{\"error\":\"Not Found\"}"}})
      assert {:error, error} == GitHub.User.connect(user, "foo_code", "foo_state")
    end
  end
end

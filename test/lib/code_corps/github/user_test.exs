defmodule CodeCorps.GitHub.UserTest do
  @moduledoc false

  use CodeCorps.ModelCase
  use CodeCorps.GitHubCase

  alias CodeCorps.{GitHub, GithubAppInstallation, User}

  @user_data %{
    "avatar_url" => "foo_url",
    "email" => "foo_email",
    "id" => 123,
    "login" => "foo_login"
  }

  @token_data %{"access_token" => "foo_auth_token"}

  describe "connect/2" do
    @tag bypass: %{"/user" => {200, @user_data}, "/" => {200, @token_data}}
    test "posts to github, associates user and installations, returns updated user" do
      user = insert(:user)

      # 3 test installations
      # this one should associate, because it's orphaned and matches github id
      installation_1 = insert(:github_app_installation, user: nil, sender_github_id: 123)
      # this one matches github id, but is not orphaned, so should not associate
      installation_2 = insert(:github_app_installation, sender_github_id: 123)
      # this one is orphaned, but does not match github id, should not associate
      installation_3 = insert(:github_app_installation, user: nil, sender_github_id: 234)

      {:ok, %User{} = returned_user} = GitHub.User.connect(user, "foo_code", "foo_state")

      assert returned_user.id == user.id
      assert returned_user.github_auth_token == "foo_auth_token"
      assert returned_user.github_avatar_url == "foo_url"
      assert returned_user.email == "foo_email"
      assert returned_user.github_id == 123
      assert returned_user.github_username == "foo_login"

      assert Enum.count(returned_user.github_app_installations) == 1

      assert Repo.get(GithubAppInstallation, installation_1.id).user_id == returned_user.id
      refute Repo.get(GithubAppInstallation, installation_2.id).user_id == returned_user.id
      refute Repo.get(GithubAppInstallation, installation_3.id).user_id == returned_user.id
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

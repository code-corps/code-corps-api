defmodule CodeCorps.GitHub.UserTest do
  @moduledoc false

  use CodeCorps.DbAccessCase
  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{GitHub, GithubAppInstallation, User}

  describe "connect/2" do
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

    defmodule NotFoundRequest do
      def request(:get, "https://api.github.com/user", _, _, _) do
        {:error, GitHub.APIError.new({404, %{"message" => "{\"error\":\"Not Found\"}"}})}
      end
      def request(method, endpoint, headers, body, options) do
        CodeCorps.GitHub.SuccessAPI.request(method, endpoint, headers, body, options)
      end
    end

    test "posts to github, returns error if reply is not ok" do
      user = insert(:user)

      error = GitHub.APIError.new({404, %{"message" => "{\"error\":\"Not Found\"}"}})

      with_mock_api(NotFoundRequest) do
        assert {:error, error} == GitHub.User.connect(user, "foo_code", "foo_state")
      end
    end
  end
end

defmodule CodeCorps.GitHub.UserTest do
  @moduledoc false

  use CodeCorps.DbAccessCase
  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{GitHub, GithubAppInstallation, Task, User}

  describe "connect/2" do
    test "posts to github, returns updated user" do
      user = insert(:user)
      %{
        "avatar_url" => avatar_url,
        "email" => email,
        "id" => github_id,
        "login" => login
      } = load_endpoint_fixture("user")

      {:ok, %User{} = returned_user} = GitHub.User.connect(user, "foo_code", "foo_state")

      assert returned_user.id == user.id
      assert returned_user.github_auth_token == "foo_auth_token"
      assert returned_user.github_avatar_url == avatar_url
      assert returned_user.email == email
      assert returned_user.github_id == github_id
      assert returned_user.github_username == login
    end

    test "posts to github, associates user and installations" do
      user = insert(:user)
      %{"id" => github_id} = load_endpoint_fixture("user")

      # 3 test installations
      # this one should associate, because it's orphaned and matches github id
      installation_1 = insert(:github_app_installation, user: nil, sender_github_id: github_id)
      # this one matches github id, but is not orphaned, so should not associate
      installation_2 = insert(:github_app_installation, sender_github_id: github_id)
      # this one is orphaned, but does not match github id, should not associate
      installation_3 = insert(:github_app_installation, user: nil, sender_github_id: 234)

      {:ok, %User{} = returned_user} = GitHub.User.connect(user, "foo_code", "foo_state")

      assert Enum.count(returned_user.github_app_installations) == 1

      assert Repo.get(GithubAppInstallation, installation_1.id).user_id == returned_user.id
      refute Repo.get(GithubAppInstallation, installation_2.id).user_id == returned_user.id
      refute Repo.get(GithubAppInstallation, installation_3.id).user_id == returned_user.id
    end

    test "posts to github, associates user and tasks" do
      user = insert(:user)
      %{"id" => github_id} = load_endpoint_fixture("user")
      premade_user = insert(:user, github_id: github_id)

      # 2 test tasks
      # this one should associate,
      # because the associated user has the same github id
      task_1 = insert(:task, user: premade_user)
      # this one should not associate, because the associated user has a
      # different (or no) github id
      task_2 = insert(:task)

      {:ok, %User{} = returned_user} = GitHub.User.connect(user, "foo_code", "foo_state")

      assert Repo.get(Task, task_1.id).user_id == returned_user.id
      refute Repo.get(Task, task_2.id).user_id == returned_user.id
    end

    defmodule NotFoundRequest do
      @moduledoc false

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

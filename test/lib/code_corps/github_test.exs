defmodule CodeCorps.GitHubTest do
  use CodeCorps.ModelCase

  alias CodeCorps.{
    GitHub, User
  }

  alias Ecto.Changeset

  describe "associate/2" do
    test "updates the user, returns :ok tuple with user" do
      user = insert(:user)
      params = %{github_auth_token: "foobar"}
      {:ok, %User{} = returned_user} = GitHub.associate(user, params)
      assert user.id == returned_user.id
      assert returned_user.github_auth_token == "foobar"
    end

    test "returns :error tupple with changeset if there are validation errors" do
      user = insert(:user)
      params = %{}
      {:error, %Changeset{} = changeset} = GitHub.associate(user, params)
      refute changeset.valid?
    end
  end

  defmodule SuccessAPI do
    @behaviour CodeCorps.GitHub.APIContract
    def connect(_code), do: {:ok, "foo_auth_token"}
  end

  defmodule ErrorAPI do
    @behaviour CodeCorps.GitHub.APIContract
    def connect(_code), do: {:error, "foo_error"}
  end

  describe "connect/2" do
    test "posts to github, updates user if reply is ok, returns updated user" do
      user = insert(:user)

      {:ok, %User{} = returned_user} = GitHub.connect(user, "foo", SuccessAPI)

      assert returned_user.id == user.id
      assert returned_user.github_auth_token == "foo_auth_token"
    end

    test "posts to github, returns error if reply is not ok" do
      user = insert(:user)
      assert {:error, "foo_error"} == GitHub.connect(user, "foo", ErrorAPI)
    end
  end
end

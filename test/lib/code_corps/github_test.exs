defmodule CodeCorps.GithubTest do
  use CodeCorps.ModelCase

  alias CodeCorps.{
    Github, User
  }

  alias Ecto.Changeset

  describe "associate/2" do
    test "updates the user, returns :ok tuple with user" do
      user = insert(:user)
      params = %{github_auth_token: "foobar"}
      {:ok, %User{} = returned_user} = Github.associate(user, params)
      assert user.id == returned_user.id
      assert returned_user.github_auth_token == "foobar"
    end

    test "returns :error tupple with changeset if there are validation errors" do
      user = insert(:user)
      params = %{}
      {:error, %Changeset{} = changeset} = Github.associate(user, params)
      refute changeset.valid?
    end
  end

  defmodule SuccessAPI do
    @behaviour CodeCorps.Github.APIContract
    def connect(_code), do: {:ok, "foo_auth_token"}
  end

  defmodule ErrorAPI do
    @behaviour CodeCorps.Github.APIContract
    def connect(_code), do: {:error, "foo_error"}
  end

  describe "connect/2" do
    test "posts to github, updates user if reply is ok, returns updated user" do
      user = insert(:user)

      {:ok, %User{} = returned_user} = Github.connect(user, "foo", SuccessAPI)

      assert returned_user.id == user.id
      assert returned_user.github_auth_token == "foo_auth_token"
    end

    test "posts to github, returns error if reply is not ok" do
      user = insert(:user)
      assert {:error, "foo_error"} == Github.connect(user, "foo", ErrorAPI)
    end
  end
end

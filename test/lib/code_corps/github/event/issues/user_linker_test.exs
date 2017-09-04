defmodule CodeCorps.GitHub.Event.Issues.UserLinkerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.Issues.UserLinker,
    Repo,
    User
  }

  alias CodeCorps.GitHub.Adapters.User, as: UserAdapter

  @payload load_event_fixture("issues_opened")
  @user_payload @payload["issue"]["user"]

  describe "find_or_create_user/1" do
    test "creates user if none is found" do
      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(@payload)

      assert Repo.one(User)

      created_attributes = UserAdapter.from_github_user(@user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "returns user if one is found" do
      attributes = UserAdapter.from_github_user(@user_payload)
      preinserted_user = insert(:user, attributes)

      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(@payload)

      assert preinserted_user.id == returned_user.id

      assert Repo.one(User)
    end
  end
end

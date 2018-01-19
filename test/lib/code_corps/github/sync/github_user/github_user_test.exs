defmodule CodeCorps.GitHub.Sync.GithubUserTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Adapters,
    GitHub.Sync,
    GithubUser,
    Repo
  }

  alias Ecto.Changeset



  @event_payload "issues_opened" |> load_event_fixture() |> Map.get("issue")

  describe "create_or_update_github_user/1" do
    test "creates github user if one is not matched from the payload" do
      assert {:ok, %GithubUser{id: created_id}} =
        @event_payload |> Sync.GithubUser.create_or_update_github_user()

      assert created_user = Repo.one(GithubUser)
      assert created_user.id == created_id
      attrs = Adapters.User.to_github_user(@event_payload["user"])
      assert created_user |> Map.take(attrs |> Map.keys()) == attrs
    end

    test "updates github user if one is matched from the payload" do
      record = insert(:github_user, github_id: @event_payload["user"]["id"])

      assert {:ok, %GithubUser{id: updated_id}} =
        @event_payload |> Sync.GithubUser.create_or_update_github_user()

      assert updated_user = Repo.one(GithubUser)
      assert updated_user.id == updated_id
      assert updated_user.id == record.id
      attrs = Adapters.User.to_github_user(@event_payload["user"])
      assert updated_user |> Map.take(attrs |> Map.keys()) == attrs
    end

    test "returns changeset if there was a problem" do
      assert {:error, %Changeset{} = changeset} =
        @event_payload
        |> Kernel.put_in(["user", "login"], nil)
        |> Sync.GithubUser.create_or_update_github_user()

      refute changeset.valid?
      refute Repo.one(GithubUser)
    end
  end
end

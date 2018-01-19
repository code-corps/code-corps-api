defmodule CodeCorps.GitHub.Event.GithubUser.ChangesetTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers
  alias CodeCorps.{
    GitHub.Adapters,
    GitHub.Sync,
    GithubUser
  }
  alias Ecto.Changeset


  describe "changeset/2" do
    test "assigns correct changes" do
      attrs =
        "issues_opened"
        |> load_event_fixture()
        |> Kernel.get_in(["issue", "user"])
        |> Adapters.User.to_github_user()

      changeset = %GithubUser{} |> Sync.GithubUser.Changeset.changeset(attrs)

      assert changeset |> Changeset.get_change(:avatar_url) == attrs.avatar_url
      assert changeset |> Changeset.get_change(:email) == attrs.email
      assert changeset |> Changeset.get_change(:github_id) == attrs.github_id
      assert changeset |> Changeset.get_change(:username) == attrs.username
      assert changeset |> Changeset.get_change(:type) == attrs.type

      assert changeset.valid?
    end

    test "validates correct required attributes" do
      changeset = %GithubUser{} |> Sync.GithubUser.Changeset.changeset(%{})

      refute changeset.valid?

      assert changeset.errors[:avatar_url]
      assert changeset.errors[:github_id]
      assert changeset.errors[:username]
      assert changeset.errors[:type]
    end
  end
end

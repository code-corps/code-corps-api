defmodule CodeCorps.GitHub.Event.Installation.ChangesetBuilderTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.{Factories, TestHelpers.GitHub}
  import Ecto.Changeset

  alias CodeCorps.{
    GitHub.Event.Installation.ChangesetBuilder,
    GithubAppInstallation
  }

  describe "build_changeset/3" do
    test "assigns proper changes to the task" do
      payload = load_event_fixture("installation_created")
      github_app_installation = %GithubAppInstallation{}
      user = insert(:user)

      changeset = ChangesetBuilder.build_changeset(
        github_app_installation, payload, user
      )

      # adapted fields
      assert get_change(changeset, :github_id) == payload["installation"]["id"]
      assert get_change(changeset, :github_account_id) == payload["installation"]["account"]["id"]
      assert get_change(changeset, :github_account_avatar_url) == payload["installation"]["account"]["avatar_url"]
      assert get_change(changeset, :github_account_login) == payload["installation"]["account"]["login"]
      assert get_change(changeset, :github_account_type) == payload["installation"]["account"]["type"]
      assert get_change(changeset, :sender_github_id) == payload["sender"]["id"]

      # other fields
      assert get_change(changeset, :installed) == true
      assert get_change(changeset, :origin) == "github"

      # relationships are proper
      assert get_change(changeset, :user_id) == user.id

      assert changeset.valid?
    end

    test "leaves origin if installation exists" do
      payload = load_event_fixture("installation_created")
      github_app_installation = insert(:github_app_installation)
      user = insert(:user)

      changeset = ChangesetBuilder.build_changeset(
        github_app_installation, payload, user
      )

      refute get_change(changeset, :origin) == "github"
      assert changeset.valid?
    end
  end

  describe "build_changeset/2" do
    test "assigns proper changes to the task" do
      payload = load_event_fixture("installation_created")
      github_app_installation = %GithubAppInstallation{}

      changeset = ChangesetBuilder.build_changeset(
        github_app_installation, payload
      )

      # adapted fields
      assert get_change(changeset, :github_id) == payload["installation"]["id"]
      assert get_change(changeset, :github_account_id) == payload["installation"]["account"]["id"]
      assert get_change(changeset, :github_account_avatar_url) == payload["installation"]["account"]["avatar_url"]
      assert get_change(changeset, :github_account_login) == payload["installation"]["account"]["login"]
      assert get_change(changeset, :github_account_type) == payload["installation"]["account"]["type"]
      assert get_change(changeset, :sender_github_id) == payload["sender"]["id"]

      # other fields
      assert get_change(changeset, :installed) == true
      assert get_change(changeset, :origin) == "github"

      # relationships are proper
      refute get_change(changeset, :user_id)

      assert changeset.valid?
    end

    test "leaves origin if installation exists" do
      payload = load_event_fixture("installation_created")
      github_app_installation = insert(:github_app_installation)

      changeset = ChangesetBuilder.build_changeset(
        github_app_installation, payload
      )

      refute get_change(changeset, :origin) == "github"
      assert changeset.valid?
    end
  end
end

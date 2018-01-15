defmodule CodeCorps.GitHub.Event.GithubAppInstallation.ChangesetTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers
  alias CodeCorps.{
    GitHub.Sync,
    GithubAppInstallation
  }
  alias Ecto.Changeset


  describe "create_changeset/2" do
    test "assigns correct changes" do
      payload = load_event_fixture("installation_created")

      changeset =
        payload |> Sync.GithubAppInstallation.Changeset.create_changeset()

      assert changeset |> Changeset.get_change(:github_id) == payload["installation"]["id"]
      assert changeset |> Changeset.get_change(:github_account_id) == payload["installation"]["account"]["id"]
      assert changeset |> Changeset.get_change(:github_account_avatar_url) == payload["installation"]["account"]["avatar_url"]
      assert changeset |> Changeset.get_change(:github_account_login) == payload["installation"]["account"]["login"]
      assert changeset |> Changeset.get_change(:github_account_type) == payload["installation"]["account"]["type"]
      assert changeset |> Changeset.get_change(:sender_github_id) == payload["sender"]["id"]
      assert changeset |> Changeset.get_change(:installed) == true
      assert changeset |> Changeset.get_change(:origin) == "github"
      assert changeset |> Changeset.get_change(:user) == nil

      assert changeset.valid?
    end

    test "assigns user if provided" do
      payload = load_event_fixture("installation_created")
      user = insert(:user)

      changeset =
        payload |> Sync.GithubAppInstallation.Changeset.create_changeset(user)

      assert changeset |> Changeset.get_change(:user) |> Map.get(:data) == user
      assert changeset.valid?
    end
  end

  describe "update_changeset/2" do
    test "assigns proper changes to the task" do
      payload = load_event_fixture("installation_created")
      github_app_installation = %GithubAppInstallation{}

      changeset =
        github_app_installation
        |> Sync.GithubAppInstallation.Changeset.update_changeset(payload)

      assert changeset |> Changeset.get_change(:github_id) == payload["installation"]["id"]
      assert changeset |> Changeset.get_change(:github_account_id) == payload["installation"]["account"]["id"]
      assert changeset |> Changeset.get_change(:github_account_avatar_url) == payload["installation"]["account"]["avatar_url"]
      assert changeset |> Changeset.get_change(:github_account_login) == payload["installation"]["account"]["login"]
      assert changeset |> Changeset.get_change(:github_account_type) == payload["installation"]["account"]["type"]
      assert changeset |> Changeset.get_change(:sender_github_id) == payload["sender"]["id"]
      assert changeset |> Changeset.get_change(:installed) == true

      refute changeset |> Changeset.get_change(:origin) == "github"
      refute changeset |> Changeset.get_change(:user)

      assert changeset.valid?
    end
  end
end

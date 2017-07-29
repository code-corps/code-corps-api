defmodule CodeCorps.GitHub.Installation.SyncerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.{Factories, TestHelpers.GitHub}

  alias CodeCorps.{
    GitHub.Installation.Syncer,
    GithubAppInstallation,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.GithubAppInstallation,
    as: GithubAppInstallationAdapter

  @payload load_endpoint_fixture("user_installations")

  describe "sync" do
    test "creates or updates installations in payload" do
      %{"installations" => [payload_1, payload_2] = installations} = @payload

      installation =
        insert(:github_app_installation, payload_1
        |> GithubAppInstallationAdapter.from_installation)

      {:ok, returned_installations} = Syncer.sync(installations)

      assert returned_installations |> Enum.count == 2
      assert GithubAppInstallation |> Repo.aggregate(:count, :id) == 2

      assert GithubAppInstallation |> Repo.get_by(payload_2 |> GithubAppInstallationAdapter.from_installation)

      assert installation.id in (returned_installations |> Enum.map(&Map.get(&1, :id)))
    end
  end
end

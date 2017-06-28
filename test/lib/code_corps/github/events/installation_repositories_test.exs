defmodule CodeCorps.GitHub.Events.InstallationRepositoriesTest do
  @moduledoc false

  use ExUnit.Case, aysnc: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubEvent,
    GitHub.Events.InstallationRepositories
  }

  describe "handle/2" do
    test "is not implemented" do
      payload = load_event_fixture("installation_repositories_removed")
      assert InstallationRepositories.handle(%GithubEvent{}, payload) == :not_fully_implemented
    end
  end
end

defmodule CodeCorps.GitHub.Adapters.GithubAppInstallationTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.GitHub.Adapters.GithubAppInstallation

  describe "from_installation_event/1" do
    test "maps api payload correctly" do
      payload = load_event_fixture("installation_created")

      assert GithubAppInstallation.from_installation_event(payload) == %{
        github_id: payload["installation"]["id"],
        github_account_id: payload["installation"]["account"]["id"],
        github_account_login: payload["installation"]["account"]["login"],
        github_account_avatar_url: payload["installation"]["account"]["avatar_url"],
        github_account_type: payload["installation"]["account"]["type"],
        sender_github_id: payload["sender"]["id"],
      }
    end
  end
end

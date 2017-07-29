defmodule CodeCorps.GitHub.Adapters.GithubAppInstallationTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.GitHub.Adapters.GithubAppInstallation

  describe "from_installation/1" do
    test "maps api payload correctly" do
      %{"installations" => [payload, _]} = load_endpoint_fixture("user_installations")

      assert GithubAppInstallation.from_installation(payload) == %{
        github_id: payload["id"],
        # 851 needs to close to add these
        # github_account_id: payload["account"]["id"],
        # github_account_login: payload["account"]["login"],
        # github_account_avatar_url: payload["account"]["avatar_url"],
        # github_account_type: payload["account"]["type"],
      }
    end
  end
end

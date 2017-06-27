defmodule CodeCorps.GitHub.Events.InstallationTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubEvent,
    GitHub.Events.Installation
  }

  describe "handle/2" do
    test "is not implemented" do
      payload = load_fixture("installation_created")
      assert Installation.handle(%GithubEvent{}, payload) == :not_fully_implemented
    end
  end
end

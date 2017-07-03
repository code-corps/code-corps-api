defmodule CodeCorps.GitHub.Event.IssuesTest do
  @moduledoc false

  use ExUnit.Case, aysnc: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubEvent,
    GitHub.Event.Issues
  }

  describe "handle/2" do
    test "is not implemented" do
      payload = load_event_fixture("issues_opened")
      assert Issues.handle(%GithubEvent{}, payload) == :not_fully_implemented
    end
  end
end

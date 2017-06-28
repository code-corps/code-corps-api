defmodule CodeCorps.GitHub.Events.IssueCommentTest do
  @moduledoc false

  use ExUnit.Case, aysnc: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubEvent,
    GitHub.Events.IssueComment
  }

  describe "handle/2" do
    test "is not implemented" do
      payload = load_event_fixture("issue_comment_created")
      assert IssueComment.handle(%GithubEvent{}, payload) == :not_fully_implemented
    end
  end
end

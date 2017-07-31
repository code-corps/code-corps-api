defmodule CodeCorps.GitHub.Adapters.CommentTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.GitHub.Adapters.Comment

  describe "from_api/1" do
    test "maps api payload correctly" do
      payload = load_event_fixture("issue_comment_created")

      assert Comment.from_api(payload) == %{
        github_id: payload["id"],
        markdown: payload["body"]
      }
    end
  end
end

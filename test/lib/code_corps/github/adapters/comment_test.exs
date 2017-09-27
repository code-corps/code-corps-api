defmodule CodeCorps.GitHub.Adapters.CommentTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{GitHub.Adapters, Comment}

  describe "from_api/1" do
    test "maps api payload correctly" do
      payload = load_event_fixture("issue_comment_created")

      assert Adapters.Comment.from_api(payload) == %{
        github_id: payload["id"],
        markdown: payload["body"]
      }
    end
  end

  describe "to_github_comment/1" do
    test "maps Comment correctly" do
      payload =
        %Comment{github_id: 6, markdown: "bar"}
        |> Adapters.Comment.to_github_comment

      assert payload["body"] == "bar"
      refute payload["id"]
    end
  end
end

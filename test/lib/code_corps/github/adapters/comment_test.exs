defmodule CodeCorps.GitHub.Adapters.CommentTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{GitHub.Adapters, Comment}

  describe "from_api/1" do
    test "maps api payload correctly" do
      payload = load_event_fixture("issue_comment_created")

      assert Adapters.Comment.from_api(payload) == %{
        created_at: payload["created_at"],
        github_id: payload["id"],
        markdown: payload["body"],
        modified_at: payload["updated_at"]
      }
    end
  end

  describe "to_api/1" do
    test "maps Comment correctly" do
      payload =
        %Comment{github_id: 6, markdown: "bar"}
        |> Adapters.Comment.to_api

      assert payload["body"] == "bar"
      refute payload["id"]
      refute payload["created_at"]
      refute payload["updated_at"]
    end
  end
end

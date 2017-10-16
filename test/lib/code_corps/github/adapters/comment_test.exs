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
        markdown: payload["body"],
        modified_at: payload["updated_at"]
      }
    end
  end

  describe "to_api/1" do
    test "maps Comment correctly" do
      payload =
        %Comment{markdown: "bar"}
        |> Adapters.Comment.to_api

      assert payload["body"] == "bar"
      refute payload["created_at"]
      refute payload["updated_at"]
    end
  end

  describe "to_github_comment/1" do
    test "maps from api payload correctly" do
      %{"comment" => payload} = load_event_fixture("issue_comment_created")

      assert Adapters.Comment.to_github_comment(payload) == %{
        body: payload["body"],
        github_created_at: payload["created_at"],
        github_id: payload["id"],
        github_updated_at: payload["updated_at"],
        html_url: payload["html_url"],
        url: payload["url"]
      }
    end
  end
end

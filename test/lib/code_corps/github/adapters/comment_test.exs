defmodule CodeCorps.GitHub.Adapters.CommentTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{GitHub.Adapters, Comment}

  describe "to_comment/1" do
    test "maps GithubComment correctly" do
      github_comment = insert(:github_comment)

      assert Adapters.Comment.to_comment(github_comment) == %{
        created_at: github_comment.github_created_at,
        markdown: github_comment.body,
        modified_at: github_comment.github_updated_at
      }
    end

    test "removes 'Posted by' header from body if one is present" do
      header =
        "Posted by \r\n\r\n[//]: # (Please type your edits below this line)\r\n\r\n---\r\n\r\n"
      body = "test"

      github_comment = insert(:github_comment, body: header <> body)

      assert Adapters.Comment.to_comment(github_comment) == %{
        created_at: github_comment.github_created_at,
        markdown: body,
        modified_at: github_comment.github_updated_at
      }
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

  describe "to_api/1" do
    test "maps Comment correctly" do
      payload =
        %Comment{markdown: "bar"}
        |> Adapters.Comment.to_api

      assert payload["body"] == "bar"
      refute payload["created_at"]
      refute payload["updated_at"]
    end

    test "adds 'Posted by' header to body if comment user is not github connected" do
      user = insert(:user, github_id: nil)
      comment = insert(:comment, user: user)
      payload = comment |> Adapters.Comment.to_api

      assert payload["body"] =~ "Posted by"
    end
  end
end

defmodule CodeCorps.GitHub.API.CommentTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.API.Comment,
    GitHub.Adapters
  }

  describe "create/1" do
    test "calls github API to create a github comment for assigned comment, makes user request if user is connected, returns response" do
      github_issue = insert(:github_issue, number: 5)
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: "baz")
      task = insert(:task, github_issue: github_issue, github_repo: github_repo)
      comment = insert(:comment, task: task, user: user)

      assert Comment.create(comment)

      assert_received({
        :post,
        "https://api.github.com/repos/foo/bar/issues/5/comments",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token baz"}
        ],
        body,
        _options
      })

      assert body == Adapters.Comment.to_api(comment) |> Poison.encode!
    end

    test "calls github API to create a github comment for assigned comment, makes integration request if user is not connected, returns response" do
      github_issue = insert(:github_issue, number: 5)
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: nil)
      task = insert(:task, github_issue: github_issue, github_repo: github_repo)
      comment = insert(:comment, task: task, user: user)

      assert Comment.create(comment)

      assert_received({
        :post,
        "https://api.github.com/repos/foo/bar/issues/5/comments",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        body,
        _options
      })

      assert body == Adapters.Comment.to_api(comment) |> Poison.encode!
    end

    test "returns error response if there was trouble" do
      github_issue = insert(:github_issue, number: 5)
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: nil)
      task = insert(:task, github_issue: github_issue, github_repo: github_repo)
      comment = insert(:comment, task: task, user: user)

      with_mock_api CodeCorps.GitHub.FailureAPI do
        assert Comment.create(comment)
      end

      assert_received({
        :post,
        "https://api.github.com/repos/foo/bar/issues/5/comments",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        body,
        _options
      })

      assert body == Adapters.Comment.to_api(comment) |> Poison.encode!
    end
  end

  describe "update/1" do
    test "calls github API to update a github comment for assigned comment, makes user request if user is connected, returns response" do
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      github_issue = insert(:github_issue, number: 5, github_repo: github_repo)
      user = insert(:user, github_auth_token: "baz")
      task = insert(:task, github_issue: github_issue, github_repo: github_repo)

      github_comment = insert(:github_comment, github_id: 6, github_issue: github_issue)
      comment = insert(:comment, task: task, user: user, github_comment: github_comment)

      assert Comment.update(comment)

      assert_received({
        :patch,
        "https://api.github.com/repos/foo/bar/issues/comments/6",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        body,
        _options
      })

      assert body == Adapters.Comment.to_api(comment) |> Poison.encode!
    end

    test "calls github API to update a github comment for assigned comment, makes integration request if user is not connected, returns response" do
      github_issue = insert(:github_issue, number: 5)
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: nil)
      task = insert(:task, github_issue: github_issue, github_repo: github_repo)

      github_comment = insert(:github_comment, github_id: 6, github_issue: github_issue)
      comment = insert(:comment, task: task, user: user, github_comment: github_comment)

      assert Comment.update(comment)

      assert_received({
        :patch,
        "https://api.github.com/repos/foo/bar/issues/comments/6",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        body,
        _options
      })

      assert body == Adapters.Comment.to_api(comment) |> Poison.encode!
    end

    test "returns error response if there was trouble" do
      github_issue = insert(:github_issue, number: 5)
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: nil)
      task = insert(:task, github_issue: github_issue, github_repo: github_repo)

      github_comment = insert(:github_comment, github_id: 6, github_issue: github_issue)
      comment = insert(:comment, task: task, user: user, github_comment: github_comment)

      with_mock_api CodeCorps.GitHub.FailureAPI do
        assert Comment.update(comment)
      end

      assert_received({
        :patch,
        "https://api.github.com/repos/foo/bar/issues/comments/6",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        body,
        _options
      })

      assert body == Adapters.Comment.to_api(comment) |> Poison.encode!
    end
  end
end

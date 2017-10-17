defmodule CodeCorps.GitHub.IssueTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Issue,
    GitHub.Adapters
  }

  describe "create/1" do
    test "calls github API to create an issue for assigned task, makes user request if user is connected, returns response" do
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: "baz")
      task = insert(:task, github_repo: github_repo, user: user)

      assert Issue.create(task)

      assert_received({
        :post,
        "https://api.github.com/repos/foo/bar/issues",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token baz"}
        ],
        body,
        _options
      })

      assert body == Adapters.Issue.to_api(task) |> Poison.encode!
    end

    test "calls github API to create an issue for assigned task, makes integration request if user is not connected, returns response" do
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: nil)
      task = insert(:task, github_repo: github_repo, user: user)

      assert Issue.create(task)

      assert_received({
        :post,
        "https://api.github.com/repos/foo/bar/issues",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        body,
        _options
      })

      assert body == Adapters.Issue.to_api(task) |> Poison.encode!
    end

    test "returns error response if there was trouble" do
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: nil)
      task = insert(:task, github_repo: github_repo, user: user)

      with_mock_api CodeCorps.GitHub.FailureAPI do
        assert Issue.create(task)
      end

      assert_received({
        :post,
        "https://api.github.com/repos/foo/bar/issues",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        body,
        _options
      })

      assert body == Adapters.Issue.to_api(task) |> Poison.encode!
    end
  end

  describe "update/1" do
    test "calls github API to create an issue for assigned task, makes user request if user is connected, returns response" do
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: "baz")
      github_issue = insert(:github_issue, number: 5)
      task = insert(:task, github_issue: github_issue, github_repo: github_repo, user: user)

      assert Issue.update(task)

      assert_received({
        :patch,
        "https://api.github.com/repos/foo/bar/issues/5",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token baz"}
        ],
        body,
        _options
      })

      assert body == Adapters.Issue.to_api(task) |> Poison.encode!
    end

    test "calls github API to create an issue for assigned task, makes integration request if user is not connected, returns response" do
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: nil)
      github_issue = insert(:github_issue, number: 5)
      task = insert(:task, github_issue: github_issue, github_repo: github_repo, user: user)

      assert Issue.update(task)

      assert_received({
        :patch,
        "https://api.github.com/repos/foo/bar/issues/5",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        body,
        _options
      })

      assert body == Adapters.Issue.to_api(task) |> Poison.encode!
    end

    test "returns error response if there was trouble" do
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: nil)
      github_issue = insert(:github_issue, number: 5)
      task = insert(:task, github_issue: github_issue, github_repo: github_repo, user: user)

      with_mock_api CodeCorps.GitHub.FailureAPI do
        assert Issue.update(task)
      end

      assert_received({
        :patch,
        "https://api.github.com/repos/foo/bar/issues/5",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        body,
        _options
      })

      assert body == Adapters.Issue.to_api(task) |> Poison.encode!
    end
  end
end

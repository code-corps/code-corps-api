defmodule CodeCorps.GitHub.API.IssueTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.API.Issue,
    GitHub.Adapters
  }

  describe "from_url/2" do
    test "calls github API to create an issue for assigned task, makes user request if user is connected, returns response" do
      url = "https://api.github.com/repos/baxterthehacker/public-repo/issues/1"
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")

      assert Issue.from_url(url, github_repo)
      assert_received({
        :get,
        endpoint_url,
        _body,
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        _options
      })
      assert endpoint_url == url
    end
  end

  describe "create/1" do
    test "calls github API to create an issue for assigned task, makes user request if user is connected, returns response" do
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      user = insert(:user, github_auth_token: "baz")
      task = insert(:task, github_repo: github_repo, user: user)

      assert Issue.create(task)

      assert_received({
        :post,
        "https://api.github.com/repos/foo/bar/issues",
        body,
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token baz"}
        ],
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
        body,
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
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
        body,
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
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
        body,
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token baz"}
        ],
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
        body,
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
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
        body,
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        _options
      })

      assert body == Adapters.Issue.to_api(task) |> Poison.encode!
    end
  end
end

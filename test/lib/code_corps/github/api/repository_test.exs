defmodule CodeCorps.GitHub.API.RepositoryTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.API.Repository
  }

  describe "issues/1" do
    test "calls github API for issues returns response" do
      owner = "baxterthehacker"
      repo = "public-repo"
      url = "https://api.github.com/repos/#{owner}/#{repo}/issues"
      github_app_installation = insert(:github_app_installation, github_account_login: owner)
      github_repo = insert(:github_repo, github_app_installation: github_app_installation, name: repo)

      {:ok, issues} = Repository.issues(github_repo)

      assert_received({
        :get,
        endpoint_url,
        "",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        [
          {:params, [page: 1, per_page: 100, state: "all"]},
          {:access_token, "v1.1f699f1069f60xxx"}
        ]
      })
      assert url == endpoint_url
      assert Enum.count(issues) == 8
    end

    @tag acceptance: true
    test "calls github API with the real API" do
      owner = "coderly"
      repo = "github-app-testing"
      github_app_installation = insert(:github_app_installation, github_account_login: owner, github_id: 63365)
      github_repo = insert(:github_repo, github_app_installation: github_app_installation, name: repo)

      with_real_api do
        {:ok, issues} = Repository.issues(github_repo)
        assert Enum.count(issues) == 3
      end
    end
  end

  describe "issue_comments/1" do
    test "calls github API for issues returns response" do
      owner = "baxterthehacker"
      repo = "public-repo"
      url = "https://api.github.com/repos/#{owner}/#{repo}/issues/comments"
      github_app_installation = insert(:github_app_installation, github_account_login: owner)
      github_repo = insert(:github_repo, github_app_installation: github_app_installation, name: repo)

      {:ok, comments} = Repository.issue_comments(github_repo)

      assert_received({
        :get,
        endpoint_url,
        "",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        [
          {:params, [page: 1, per_page: 100]},
          {:access_token, "v1.1f699f1069f60xxx"}
        ]
      })
      assert url == endpoint_url
      assert Enum.count(comments) == 12
    end

    @tag acceptance: true
    test "calls github API with the real API" do
      owner = "coderly"
      repo = "github-app-testing"
      github_app_installation = insert(:github_app_installation, github_account_login: owner, github_id: 63365)
      github_repo = insert(:github_repo, github_app_installation: github_app_installation, name: repo)

      with_real_api do
        {:ok, comments} = Repository.issue_comments(github_repo)
        assert Enum.count(comments) == 2
      end
    end
  end

  describe "pulls/1" do
    test "calls github API for pulls returns response" do
      owner = "baxterthehacker"
      repo = "public-repo"
      url = "https://api.github.com/repos/#{owner}/#{repo}/pulls"
      github_app_installation = insert(:github_app_installation, github_account_login: owner)
      github_repo = insert(:github_repo, github_app_installation: github_app_installation, name: repo)

      {:ok, pulls} = Repository.pulls(github_repo)

      assert_received({
        :get,
        endpoint_url,
        "",
        [
          {"Accept", "application/vnd.github.machine-man-preview+json"},
          {"Authorization", "token" <> _tok}
        ],
        [
          {:params, [page: 1, per_page: 100, state: "all"]},
          {:access_token, "v1.1f699f1069f60xxx"}
        ]
      })
      assert url == endpoint_url
      assert Enum.count(pulls) == 4
    end

    @tag acceptance: true
    test "calls github API with the real API" do
      owner = "coderly"
      repo = "github-app-testing"
      github_app_installation = insert(:github_app_installation, github_account_login: owner, github_id: 63365)
      github_repo = insert(:github_repo, github_app_installation: github_app_installation, name: repo)

      with_real_api do
        {:ok, pulls} = Repository.pulls(github_repo)
        assert Enum.count(pulls) == 1
      end
    end
  end
end

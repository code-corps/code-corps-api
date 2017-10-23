defmodule CodeCorps.GitHub.Webhook.HandlerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GithubEvent,
    GitHub.Webhook.Handler,
    Repo
  }

  describe "handle" do
    test "handles issues 'opened' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("issues_opened")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle("issues", "abc-123", payload)

      assert event.action == "opened"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "issues"
    end

    test "handles issues 'closed' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("issues_closed")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle("issues", "abc-123", payload)

      assert event.action == "closed"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "issues"
    end

    test "handles issues 'edited' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("issues_edited")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle("issues", "abc-123", payload)

      assert event.action == "edited"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "issues"
    end

    test "handles issues 'reopened' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("issues_reopened")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle("issues", "abc-123", payload)

      assert event.action == "reopened"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "issues"
    end

    test "handles issue_comment 'created' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("issue_comment_created")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle("issue_comment", "abc-123", payload)

      assert event.action == "created"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "issue_comment"
    end

    test "handles issue_comment 'edited' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("issue_comment_edited")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle("issue_comment", "abc-123", payload)

      assert event.action == "edited"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "issue_comment"
    end

    test "handles issue_comment 'deleted' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("issue_comment_deleted")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle("issue_comment", "abc-123", payload)

      assert event.action == "deleted"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "issue_comment"
    end

    test "handles installation_repositories 'added' event" do
      %{
        "installation" => %{
          "id" => installation_id
        }
      } = payload = load_event_fixture("installation_repositories_added")

      insert(:github_app_installation, github_id: installation_id)

      assert Handler.handle("installation_repositories", "abc-123", payload)

      event = Repo.one(GithubEvent)

      assert event.action == "added"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "installation_repositories"
    end

    test "handles installation_repositories 'removed' event" do
      %{
        "installation" => %{
          "id" => installation_id
        }
      } = payload = load_event_fixture("installation_repositories_removed")

      insert(:github_app_installation, github_id: installation_id)

      assert Handler.handle("installation_repositories", "abc-123", payload)

      event = Repo.one(GithubEvent)

      assert event.action == "removed"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "installation_repositories"
    end

    @installation_created_payload load_event_fixture("installation_created")

    test "handles installation 'created' event" do
      assert Handler.handle("installation", "abc-123", @installation_created_payload)

      event = Repo.one(GithubEvent)

      assert event.action == "created"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == @installation_created_payload
      assert event.status == "processed"
      assert event.type == "installation"
    end
  end
end

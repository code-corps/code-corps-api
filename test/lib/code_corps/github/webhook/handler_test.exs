defmodule CodeCorps.GitHub.Webhook.HandlerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubEvent,
    GitHub.Webhook.Handler,
    Repo
  }

  describe "handle" do
    test "handles issues event" do
      payload = load_event_fixture("issues_opened")

      assert Handler.handle("issues", "abc-123", payload) == :not_fully_implemented

      event = Repo.one(GithubEvent)

      assert event.action == "opened"
      assert event.github_delivery_id == "abc-123"
      assert event.status == "unprocessed"
      assert event.source == "not implemented"
      assert event.type == "issues"
    end

    test "handles issue_comment event" do
      payload = load_event_fixture("issue_comment_created")

      assert Handler.handle("issue_comment", "abc-123", payload) == :not_fully_implemented

      event = Repo.one(GithubEvent)

      assert event.action == "created"
      assert event.github_delivery_id == "abc-123"
      assert event.status == "unprocessed"
      assert event.source == "not implemented"
      assert event.type == "issue_comment"
    end

    test "handles installation_repositories event" do
      payload = load_event_fixture("installation_repositories_removed")

      assert Handler.handle("installation_repositories", "abc-123", payload) == :not_fully_implemented

      event = Repo.one(GithubEvent)

      assert event.action == "removed"
      assert event.github_delivery_id == "abc-123"
      assert event.status == "unprocessed"
      assert event.source == "not implemented"
      assert event.type == "installation_repositories"
    end

    test "handles installation event" do
      payload = load_event_fixture("installation_created")

      assert Handler.handle("installation", "abc-123", payload)

      event = Repo.one(GithubEvent)

      assert event.action == "created"
      assert event.github_delivery_id == "abc-123"
      assert event.status == "processed"
      assert event.source == "not implemented"
      assert event.type == "installation"
    end
  end
end

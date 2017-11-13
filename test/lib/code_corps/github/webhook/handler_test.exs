defmodule CodeCorps.GitHub.Webhook.HandlerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GithubEvent,
    GitHub.Webhook.Handler,
    Repo
  }

  describe "handle_supported/3" do
    test "handles issues 'opened' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("issues_opened")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("issues", "abc-123", payload)

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

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("issues", "abc-123", payload)

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

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("issues", "abc-123", payload)

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

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("issues", "abc-123", payload)

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

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("issue_comment", "abc-123", payload)

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

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("issue_comment", "abc-123", payload)

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

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("issue_comment", "abc-123", payload)

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

      assert Handler.handle_supported("installation_repositories", "abc-123", payload)

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

      assert Handler.handle_supported("installation_repositories", "abc-123", payload)

      event = Repo.one(GithubEvent)

      assert event.action == "removed"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "installation_repositories"
    end

    @installation_created_payload load_event_fixture("installation_created")

    test "handles installation 'created' event" do
      assert Handler.handle_supported("installation", "abc-123", @installation_created_payload)

      event = Repo.one(GithubEvent)

      assert event.action == "created"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == @installation_created_payload
      assert event.status == "processed"
      assert event.type == "installation"
    end

    test "handles pull_request 'opened' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("pull_request_opened")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("pull_request", "abc-123", payload)

      assert event.action == "opened"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "pull_request"
    end

    test "handles pull_request 'edited' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("pull_request_edited")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("pull_request", "abc-123", payload)

      assert event.action == "edited"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "pull_request"
    end

    test "handles pull_request 'closed' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("pull_request_closed")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("pull_request", "abc-123", payload)

      assert event.action == "closed"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "pull_request"
    end

    test "handles pull_request 'reopened' event" do
      %{"repository" => %{"id" => github_repo_id}}
        = payload = load_event_fixture("pull_request_reopened")

      insert(:github_repo, github_id: github_repo_id)

      {:ok, %GithubEvent{} = event} = Handler.handle_supported("pull_request", "abc-123", payload)

      assert event.action == "reopened"
      assert event.github_delivery_id == "abc-123"
      assert event.payload == payload
      assert event.status == "processed"
      assert event.type == "pull_request"
    end
  end

  describe "handle_unsupported/3" do
    [
      {"installation", "deleted"},
      {"issues", "assigned"},
      {"issues", "unassigned"},
      {"issues", "labeled"},
      {"issues", "unlabeled"},
      {"issues", "milestoned"},
      {"issues", "demilestoned"},
      {"pull_request", "assigned"},
      {"pull_request", "unassigned"},
      {"pull_request", "labeled"},
      {"pull_request", "unlabeled"},
      {"pull_request", "milestoned"},
      {"pull_request", "demilestoned"},
      {"pull_request", "synchronize"}
    ] |> Enum.each(fn {type, action} ->
      @event_type type
      @action action

      test "stores #{type} '#{action}' as ignored" do
        {:ok, %GithubEvent{} = event} =
          Handler.handle_unsupported(@event_type, "foo", %{"action" => @action})

        assert event.status == "unsupported"
        assert event.type == @event_type
        assert event.action == @action
        assert event.github_delivery_id == "foo"
        assert event.payload == %{"action" => @action}
      end
    end)
  end
end

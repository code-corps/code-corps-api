defmodule CodeCorps.GitHub.Adapters.IssueTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{GitHub.Adapters, GithubIssue, Task}

  describe "to_issue/1" do
    test "maps api payload correctly" do
      %{"issue" => payload} = load_event_fixture("issues_opened")

      assert Adapters.Issue.to_issue(payload) == %{
        body: payload["body"],
        closed_at: payload["closed_at"],
        comments_url: payload["comments_url"],
        events_url: payload["events_url"],
        github_created_at: payload["created_at"],
        github_id: payload["id"],
        github_updated_at: payload["updated_at"],
        html_url: payload["html_url"],
        labels_url: payload["labels_url"],
        locked: payload["locked"],
        number: payload["number"],
        state: payload["state"],
        title: payload["title"],
        url: payload["url"]
      }
    end
  end

  describe "to_task/1" do
    test "maps api payload correctly" do
      %{"issue" => payload} = load_event_fixture("issues_opened")

      assert Adapters.Issue.to_task(payload) == %{
        created_at: payload["created_at"],
        markdown: payload["body"],
        modified_at: payload["updated_at"],
        status: payload["state"],
        title: payload["title"]
      }
    end
  end

  describe "to_api/1" do
    test "maps GithubIssue correctly" do
      payload =
        %GithubIssue{body: "bar", locked: false, number: 5, state: "open", title: "Foo"}
        |> Adapters.Issue.to_api

      assert payload["body"] == "bar"
      assert payload["locked"] == false
      assert payload["state"] == "open"
      assert payload["title"] == "Foo"
      refute payload["closed_at"]
      refute payload["comments_url"]
      refute payload["created_at"]
      refute payload["events_url"]
      refute payload["html_url"]
      refute payload["id"]
      refute payload["labels_url"]
      refute payload["number"]
      refute payload["updated_at"]
      refute payload["url"]
    end

    test "maps Task correctly" do
      payload =
        %Task{created_at: DateTime.utc_now, markdown: "bar", modified_at: DateTime.utc_now, status: "open", title: "Foo"}
        |> Adapters.Issue.to_api

      assert payload["body"] == "bar"
      assert payload["state"] == "open"
      assert payload["title"] == "Foo"
      refute payload["closed_at"]
      refute payload["comments_url"]
      refute payload["created_at"]
      refute payload["events_url"]
      refute payload["html_url"]
      refute payload["id"]
      refute payload["labels_url"]
      refute payload["number"]
      refute payload["updated_at"]
      refute payload["url"]
    end
  end
end

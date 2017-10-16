defmodule CodeCorps.GitHub.Adapters.PullRequestTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GitHub.Adapters.PullRequest

  describe "from_api/1" do
    test "maps api payload correctly" do
      %{"pull_request" => payload} = load_event_fixture("pull_request_opened")

      assert PullRequest.from_api(payload) == %{
        additions: payload["additions"],
        body: payload["body"],
        changed_files: payload["changed_files"],
        closed_at: payload["closed_at"],
        comments: payload["comments"],
        comments_url: payload["comments_url"],
        commits: payload["commits"],
        commits_url: payload["commits_url"],
        deletions: payload["deletions"],
        diff_url: payload["diff_url"],
        github_created_at: payload["created_at"],
        github_id: payload["id"],
        github_updated_at: payload["updated_at"],
        html_url: payload["html_url"],
        issue_url: payload["issue_url"],
        locked: payload["locked"],
        merge_commit_sha: payload["merge_commit_sha"],
        mergeable_state: payload["mergeable_state"],
        merged: payload["merged"],
        merged_at: payload["merged_at"],
        number: payload["number"],
        patch_url: payload["patch_url"],
        review_comment_url: payload["review_comment_url"],
        review_comments: payload["review_comments"],
        review_comments_url: payload["review_comments_url"],
        state: payload["state"],
        statuses_url: payload["statuses_url"],
        title: payload["title"],
        url: payload["url"]
      }
    end
  end
end

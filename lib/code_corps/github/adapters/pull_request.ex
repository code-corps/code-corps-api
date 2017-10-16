defmodule CodeCorps.GitHub.Adapters.PullRequest do

  @mapping [
    {:additions, ["additions"]},
    {:body, ["body"]},
    {:changed_files, ["changed_files"]},
    {:closed_at, ["closed_at"]},
    {:comments, ["comments"]},
    {:comments_url, ["comments_url"]},
    {:commits, ["commits"]},
    {:commits_url, ["commits_url"]},
    {:deletions, ["deletions"]},
    {:diff_url, ["diff_url"]},
    {:github_created_at, ["created_at"]},
    {:github_id, ["id"]},
    {:github_updated_at, ["updated_at"]},
    {:html_url, ["html_url"]},
    {:issue_url, ["issue_url"]},
    {:locked, ["locked"]},
    {:merge_commit_sha, ["merge_commit_sha"]},
    {:mergeable_state, ["mergeable_state"]},
    {:merged, ["merged"]},
    {:merged_at, ["merged_at"]},
    {:number, ["number"]},
    {:patch_url, ["patch_url"]},
    {:review_comment_url, ["review_comment_url"]},
    {:review_comments, ["review_comments"]},
    {:review_comments_url, ["review_comments_url"]},
    {:state, ["state"]},
    {:statuses_url, ["statuses_url"]},
    {:title, ["title"]},
    {:url, ["url"]}
  ]

  @spec from_api(map) :: map
  def from_api(%{} = payload) do
    payload |> CodeCorps.Adapter.MapTransformer.transform(@mapping)
  end
end

defmodule CodeCorps.GithubPullRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "github_pull_requests" do
    field :additions, :integer
    field :body, :string
    field :changed_files, :integer
    field :closed_at, :utc_datetime
    field :comments, :integer
    field :comments_url, :string
    field :commits, :integer
    field :commits_url, :string
    field :deletions, :integer
    field :diff_url, :string
    field :github_created_at, :utc_datetime
    field :github_id, :integer
    field :github_updated_at, :utc_datetime
    field :html_url, :string
    field :issue_url, :string
    field :locked, :boolean, default: false
    field :merge_commit_sha, :string
    field :mergeable_state, :string
    field :merged, :boolean, default: false
    field :merged_at, :utc_datetime
    field :number, :integer
    field :patch_url, :string
    field :review_comment_url, :string
    field :review_comments, :integer
    field :review_comments_url, :string
    field :state, :string
    field :statuses_url, :string
    field :title, :string
    field :url, :string

    belongs_to :github_repo, CodeCorps.GithubRepo

    timestamps(type: :utc_datetime)
  end

  @attrs [
    :additions, :body, :changed_files, :closed_at, :comments, :comments_url,
    :commits, :commits_url, :deletions, :diff_url, :github_created_at,
    :github_id, :github_updated_at, :html_url, :issue_url, :locked,
    :merge_commit_sha, :mergeable_state, :merged, :merged_at, :number,
    :patch_url, :review_comment_url, :review_comments, :review_comments_url,
    :state, :statuses_url, :title, :url
  ]

  @required_attrs [
    :github_created_at, :github_id, :github_updated_at, :html_url, :locked,
    :merged, :number, :state, :title
  ]

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, @attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint(:github_id)
  end

  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:github_repo_id])
    |> assoc_constraint(:github_repo)
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
  end
end

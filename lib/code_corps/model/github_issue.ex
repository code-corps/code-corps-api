defmodule CodeCorps.GithubIssue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "github_issues" do
    field :body, :string
    field :closed_at, :utc_datetime
    field :comments_url, :string
    field :events_url, :string
    field :github_created_at, :utc_datetime
    field :github_id, :integer
    field :github_updated_at, :utc_datetime
    field :html_url, :string
    field :labels_url, :string
    field :locked, :boolean
    field :number, :integer
    field :state, :string
    field :title, :string
    field :url, :string

    belongs_to :github_pull_request, CodeCorps.GithubPullRequest
    belongs_to :github_repo, CodeCorps.GithubRepo

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:body, :closed_at, :comments_url, :events_url, :github_created_at, :github_id, :github_updated_at, :html_url, :labels_url, :locked, :number, :state, :title, :url])
    |> validate_required([:comments_url, :events_url, :github_created_at, :github_id, :github_updated_at, :html_url, :labels_url, :locked, :number, :state, :title, :url])
    |> unique_constraint(:github_id)
  end

  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:github_pull_request_id, :github_repo_id])
    |> assoc_constraint(:github_pull_request)
    |> assoc_constraint(:github_repo)
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:github_pull_request_id])
    |> assoc_constraint(:github_pull_request)
  end
end

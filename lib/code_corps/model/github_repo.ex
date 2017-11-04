defmodule CodeCorps.GithubRepo do
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "github_repos" do
    field :github_account_avatar_url, :string
    field :github_account_id, :integer
    field :github_account_login, :string
    field :github_account_type, :string
    field :github_id, :integer
    field :name, :string
    field :sync_state, :string, default: "unsynced"
    field :syncing_comments_count, :integer, default: 0
    field :syncing_issues_count, :integer, default: 0
    field :syncing_pull_requests_count, :integer, default: 0

    belongs_to :github_app_installation, CodeCorps.GithubAppInstallation
    has_many :project_github_repos, CodeCorps.ProjectGithubRepo

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :github_account_id, :github_account_avatar_url, :github_account_login,
      :github_account_type, :github_app_installation_id, :github_id, :name,
      :sync_state, :syncing_comments_count, :syncing_issues_count,
      :syncing_pull_requests_count
    ])
    |> validate_required([
      :github_account_id, :github_account_avatar_url, :github_account_login,
      :github_account_type, :github_id, :name
    ])
    |> assoc_constraint(:github_app_installation)
  end

  def update_sync_changeset(struct, params) do
    struct
    |> changeset(params)
    |> validate_inclusion(:sync_state, sync_states())
  end

  def sync_states do
    ~w{
      unsynced
      fetching_pull_requests errored_fetching_pull_requests
      syncing_pull_requests errored_syncing_pull_requests
      fetching_issues errored_fetching_issues
      syncing_issues errored_syncing_issues
      fetching_comments errored_fetching_comments
      syncing_comments errored_syncing_comments
      receiving_webhooks
    }
  end
end

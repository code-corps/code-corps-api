defmodule CodeCorps.GithubAppInstallation do
  @moduledoc ~S"""
  Represents an installation of the CodeCorps app to a user or an organization on GitHub.
  """
  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "github_app_installations" do
    field :access_token, :string
    field :access_token_expires_at, :utc_datetime
    field :github_account_avatar_url, :string
    field :github_account_id, :integer
    field :github_account_login, :string
    field :github_account_type, :string
    field :github_id, :integer
    field :installed, :boolean
    field :origin, :string, default: "codecorps" # "codecorps" or "github"
    field :sender_github_id, :integer

    # "unprocessed", "processing", "processed" or "errored"
    field :state, :string, default: "unprocessed"

    belongs_to :project, CodeCorps.Project # The originating project
    belongs_to :user, CodeCorps.User

    has_many :github_repos, CodeCorps.GithubRepo
    has_many :organization_github_app_installations, CodeCorps.OrganizationGithubAppInstallation

    timestamps(type: :utc_datetime)
  end

  @doc ~S"""
  Changeset used to create a GithubAppInstallation record from CodeCorps
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:project_id, :user_id])
    |> validate_required([:project_id, :user_id])
    |> assoc_constraint(:project)
    |> assoc_constraint(:user)
    |> put_change(:origin, "codecorps")
    |> put_change(:state, "unprocessed")
  end

  @doc ~S"""
  Changeset used to refresh an access token for a GithubAppInstallation
  """
  def access_token_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:access_token, :access_token_expires_at])
    |> validate_required([:access_token, :access_token_expires_at])
  end
end

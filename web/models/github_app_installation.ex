defmodule CodeCorps.GithubAppInstallation do
  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "github_app_installations" do
    field :access_token, :string
    field :access_token_expires_at, :utc_datetime
    field :github_id, :integer
    field :installed, :boolean
    field :sender_github_id, :integer
    # "unprocessed", "processing", "processed" or "errored"
    field :state, :string, default: "unprocessed"
    # "codecorps" or "github"
    field :origin, :string, default: "codecorps"

    belongs_to :project, CodeCorps.Project # The originating project
    belongs_to :user, CodeCorps.User

    has_many :github_repos, CodeCorps.GithubRepo
    has_many :organization_github_app_installations, CodeCorps.OrganizationGithubAppInstallation

    timestamps()
  end

  @doc """
  Changeset used to create a GithubAppInstallation record from CodeCorps
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:project_id, :user_id])
    |> put_change(:state, "unprocessed")
    |> put_change(:origin, "codecorps")
    |> validate_required([:project_id, :user_id])
    |> assoc_constraint(:project)
    |> assoc_constraint(:user)
  end

  @doc """
  Changeset used to update a GithubAppInstallation record from CodeCorps
  """
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:project_id])
    |> validate_required([:project_id])
    |> assoc_constraint(:project)
  end

  def access_token_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:access_token, :access_token_expires_at])
    |> validate_required([:access_token, :access_token_expires_at])
  end
end

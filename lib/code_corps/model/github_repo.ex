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

    belongs_to :github_app_installation, CodeCorps.GithubAppInstallation
    has_many :project_github_repos, CodeCorps.ProjectGithubRepo

    timestamps(type: :utc_datetime)
  end
end

defmodule CodeCorps.GithubAppInstallationView do
  use CodeCorps.PreloadHelpers, default_preloads: ~w(github_repos organization_github_app_installations project user)a
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes ~w(github_id github_account_id github_account_avatar_url github_account_login github_account_type inserted_at installed state updated_at)a

  has_one :project, serializer: CodeCorps.ProjectView
  has_one :user, serializer: CodeCorps.UserView

  has_many :github_repos, serializer: CodeCorps.GithubRepoView, identifiers: :always
  has_many :organization_github_app_installations, serializer: CodeCorps.OrganizationGithubAppInstallationView, identifiers: :always
end

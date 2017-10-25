defmodule CodeCorpsWeb.GithubAppInstallationView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: ~w(github_repos organization_github_app_installations)a
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes ~w(github_id github_account_id github_account_avatar_url github_account_login github_account_type inserted_at installed state updated_at)a

  has_one :project, type: "project", field: :project_id
  has_one :user, type: "user", field: :user_id

  has_many :github_repos, serializer: CodeCorpsWeb.GithubRepoView, identifiers: :always
  has_many :organization_github_app_installations, serializer: CodeCorpsWeb.OrganizationGithubAppInstallationView, identifiers: :always
end

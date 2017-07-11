defmodule CodeCorps.OrganizationGithubAppInstallationView do
  use CodeCorps.PreloadHelpers, default_preloads: [:github_app_installation, :organization]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:inserted_at, :updated_at]

  has_one :github_app_installation, serializer: CodeCorps.GithubAppInstallationView
  has_one :organization, serializer: CodeCorps.OrganizationView
end

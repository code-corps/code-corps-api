defmodule CodeCorpsWeb.OrganizationGithubAppInstallationView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:github_app_installation, :organization]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:inserted_at, :updated_at]

  has_one :github_app_installation, serializer: CodeCorpsWeb.GithubAppInstallationView
  has_one :organization, serializer: CodeCorpsWeb.OrganizationView
end

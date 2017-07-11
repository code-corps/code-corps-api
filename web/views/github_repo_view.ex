defmodule CodeCorps.GithubRepoView do
  use CodeCorps.PreloadHelpers, default_preloads: [:github_app_installation]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:github_account_avatar_url, :github_account_id,
  :github_account_login, :github_account_type, :github_id, :inserted_at,
  :name, :updated_at]

  has_one :github_app_installation, serializer: CodeCorps.GithubAppInstallationView
end

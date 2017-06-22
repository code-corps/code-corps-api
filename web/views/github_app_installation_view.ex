defmodule CodeCorps.GithubAppInstallationView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project, :user]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:github_id, :inserted_at, :installed, :state, :updated_at]

  has_one :project, serializer: CodeCorps.ProjectView
  has_one :user, serializer: CodeCorps.UserView
end

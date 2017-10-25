defmodule CodeCorpsWeb.OrganizationGithubAppInstallationView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:inserted_at, :updated_at]

  has_one :github_app_installation, type: "github-app-installation", field: :github_app_installation_id
  has_one :organization, type: "organization", field: :organization_id
end

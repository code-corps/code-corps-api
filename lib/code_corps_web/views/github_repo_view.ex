defmodule CodeCorpsWeb.GithubRepoView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:github_account_avatar_url, :github_account_id,
  :github_account_login, :github_account_type, :github_id, :inserted_at,
  :name, :syncing_comments_count, :syncing_issues_count,
  :syncing_pull_requests_count, :sync_state, :updated_at]

  has_one :github_app_installation, type: "github-app-installation", field: :github_app_installation_id
end

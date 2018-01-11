defmodule CodeCorpsWeb.OrganizationView do
  @moduledoc false
  alias CodeCorps.Presenters.ImagePresenter
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :approved, :cloudinary_public_id, :description, :icon_thumb_url,
    :icon_large_url, :name, :slug, :inserted_at, :updated_at
  ]

  has_one :owner, type: "user", field: :owner_id
  has_one :slugged_route, serializer: CodeCorpsWeb.SluggedRouteView
  has_one :stripe_connect_account, type: "stripe-connect-account", serializer: CodeCorpsWeb.StripeConnectAccountView

  has_many :organization_github_app_installations, serializer: CodeCorpsWeb.OrganizationGithubAppInstallationView, identifiers: :always
  has_many :projects, serializer: CodeCorpsWeb.ProjectView, identifiers: :always

  def icon_large_url(organization, _conn), do: ImagePresenter.large(organization)

  def icon_thumb_url(organization, _conn), do: ImagePresenter.thumbnail(organization)
end

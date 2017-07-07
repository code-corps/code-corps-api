defmodule CodeCorps.OrganizationView do
  alias CodeCorps.Cloudex.CloudinaryUrl
  use CodeCorps.PreloadHelpers, default_preloads: [:organization_github_app_installations, :owner, :projects, :slugged_route, :stripe_connect_account]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
    :cloudinary_public_id, :description, :icon_thumb_url,
    :icon_large_url, :name, :slug, :inserted_at, :updated_at
  ]

  has_one :owner, serializer: CodeCorps.UserView
  has_one :slugged_route, serializer: CodeCorps.SluggedRouteView
  has_one :stripe_connect_account, serializer: CodeCorps.StripeConnectAccountView

  has_many :organization_github_app_installations, serializer: CodeCorps.OrganizationGithubAppInstallationView, identifiers: :always
  has_many :projects, serializer: CodeCorps.ProjectView, identifiers: :always

  def icon_large_url(organization, _conn) do
    CloudinaryUrl.for(organization.cloudinary_public_id, %{crop: "fill", height: 500, width: 500}, "large", organization.default_color, "organization")
  end

  def icon_thumb_url(organization, _conn) do
    CloudinaryUrl.for(organization.cloudinary_public_id, %{crop: "fill", height: 100, width: 100}, "thumb", organization.default_color, "organization")
  end
end

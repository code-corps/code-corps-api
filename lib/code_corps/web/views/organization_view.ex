defmodule CodeCorps.Web.OrganizationView do
  alias CodeCorps.Cloudex.CloudinaryUrl
  use CodeCorps.PreloadHelpers, default_preloads: [:owner, :projects, :slugged_route, :stripe_connect_account]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
    :cloudinary_public_id, :description, :icon_thumb_url,
    :icon_large_url, :name, :slug, :inserted_at, :updated_at
  ]

  has_one :owner, serializer: CodeCorps.Web.UserView
  has_one :slugged_route, serializer: CodeCorps.Web.SluggedRouteView
  has_one :stripe_connect_account, serializer: CodeCorps.Web.StripeConnectAccountView

  has_many :projects, serializer: CodeCorps.Web.ProjectView, identifiers: :always

  def icon_large_url(organization, _conn) do
    CloudinaryUrl.for(organization.cloudinary_public_id, %{crop: "fill", height: 500, width: 500}, "large", organization.default_color, "organization")
  end

  def icon_thumb_url(organization, _conn) do
    CloudinaryUrl.for(organization.cloudinary_public_id, %{crop: "fill", height: 100, width: 100}, "thumb", organization.default_color, "organization")
  end
end

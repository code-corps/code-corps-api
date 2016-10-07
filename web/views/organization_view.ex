defmodule CodeCorps.OrganizationView do
  use CodeCorps.PreloadHelpers, default_preloads: [:slugged_route, :organization_memberships, :projects]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :description, :icon_thumb_url, :icon_large_url, :slug, :inserted_at, :updated_at]

  has_one :slugged_route, serializer: CodeCorps.SluggedRouteView

  has_many :organization_memberships, serializer: CodeCorps.OrganizationMembershipView, identifiers: :always
  has_many :projects, serializer: CodeCorps.ProjectView, identifiers: :always

  def icon_large_url(organization, _conn) do
    CodeCorps.OrganizationIcon.url({organization.icon, organization}, :large)
  end

  def icon_thumb_url(organization, _conn) do
    CodeCorps.OrganizationIcon.url({organization.icon, organization}, :thumb)
  end
end

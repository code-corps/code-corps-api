defmodule CodeCorps.OrganizationView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :description, :slug, :inserted_at, :updated_at]

  has_one :slugged_route, serializer: CodeCorps.SluggedRouteView
end

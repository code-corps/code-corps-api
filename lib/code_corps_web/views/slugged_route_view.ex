defmodule CodeCorpsWeb.SluggedRouteView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:organization, :user]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:slug, :inserted_at, :updated_at]

  has_one :organization, serializer: CodeCorpsWeb.OrganizationView
  has_one :user, serializer: CodeCorpsWeb.UserView
end

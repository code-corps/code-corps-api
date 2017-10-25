defmodule CodeCorpsWeb.SluggedRouteView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:slug, :inserted_at, :updated_at]

  has_one :organization, type: "organization", field: :organization_id
  has_one :user, type: "user", field: :user_id
end

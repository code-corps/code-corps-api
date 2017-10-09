defmodule CodeCorpsWeb.OrganizationInviteView do
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :email, :fulfilled, :inserted_at, :organization_name, :updated_at
  ]
end

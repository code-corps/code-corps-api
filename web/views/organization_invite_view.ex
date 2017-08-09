defmodule CodeCorps.OrganizationInviteView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
    :email, :title, :updated_at, :inserted_at, :fulfilled
  ]
end

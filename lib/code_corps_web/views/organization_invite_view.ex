defmodule CodeCorpsWeb.OrganizationInviteView do
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :email, :title, :updated_at, :inserted_at, :fulfilled
  ]
end

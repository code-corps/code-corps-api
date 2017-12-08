defmodule CodeCorpsWeb.OrganizationInviteView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :email, :inserted_at, :organization_name, :updated_at
  ]

  has_one :organization, type: "organization", field: :organization_id
end

defmodule CodeCorps.OrganizationMembershipView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:role, :inserted_at, :updated_at]

  has_one :member, serializer: CodeCorps.UserView
  has_one :organization, serializer: CodeCorps.OrganizationView
end

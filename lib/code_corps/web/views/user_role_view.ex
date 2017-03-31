defmodule CodeCorps.Web.UserRoleView do
  use CodeCorps.PreloadHelpers, default_preloads: [:user, :role]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :user, serializer: CodeCorps.Web.UserView
  has_one :role, serializer: CodeCorps.Web.RoleView
end

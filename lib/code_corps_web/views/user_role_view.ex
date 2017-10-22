defmodule CodeCorpsWeb.UserRoleView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:user, :role]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :user, serializer: CodeCorpsWeb.UserView
  has_one :role, serializer: CodeCorpsWeb.RoleView
end

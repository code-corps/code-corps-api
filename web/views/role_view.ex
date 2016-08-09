defmodule CodeCorps.RoleView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :ability, :kind, :inserted_at, :updated_at]
end

defmodule CodeCorpsWeb.UserRoleView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :user, type: "user", field: :user_id
  has_one :role, type: "role", field: :role_id
end

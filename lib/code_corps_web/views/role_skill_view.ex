defmodule CodeCorpsWeb.RoleSkillView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :role, type: "role", field: :role_id
  has_one :skill, type: "skill", field: :skill_id
end

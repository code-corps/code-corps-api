defmodule CodeCorpsWeb.RoleView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:role_skills]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:name, :ability, :kind, :inserted_at, :updated_at]

  has_many :role_skills, serializer: CodeCorpsWeb.RoleSkillView, identifiers: :always
end

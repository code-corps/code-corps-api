defmodule CodeCorps.RoleView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :ability, :kind, :inserted_at, :updated_at]

  has_many :role_skills, serializer: CodeCorps.RoleSkillView
  has_many :skills, serializer: CodeCorps.SkillView
end

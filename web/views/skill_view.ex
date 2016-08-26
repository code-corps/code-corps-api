defmodule CodeCorps.SkillView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:title, :description, :inserted_at, :updated_at]

  has_many :role_skills, serializer: CodeCorps.RoleSkillView
  has_many :roles, serializer: CodeCorps.RoleView
end

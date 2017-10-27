defmodule CodeCorpsWeb.SkillView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:title, :description, :inserted_at, :updated_at]

  has_many :role_skills, serializer: CodeCorpsWeb.RoleSkillView, identifiers: :always
end

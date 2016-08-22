defmodule CodeCorps.ProjectSkillView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:inserted_at, :updated_at]
  
  has_one :project, serializer: CodeCorps.ProjectView
  has_one :skill, serializer: CodeCorps.SkillView

end

defmodule CodeCorps.ProjectUserView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project, :user]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:role, :inserted_at, :updated_at]

  has_one :project, serializer: CodeCorps.ProjectView
  has_one :user, serializer: CodeCorps.UserView
end

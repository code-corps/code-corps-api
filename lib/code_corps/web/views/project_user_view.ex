defmodule CodeCorps.Web.ProjectUserView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project, :user]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:role, :inserted_at, :updated_at]

  has_one :project, serializer: CodeCorps.Web.ProjectView
  has_one :user, serializer: CodeCorps.Web.UserView
end

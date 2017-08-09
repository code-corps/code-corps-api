defmodule CodeCorpsWeb.ProjectUserView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:project, :user]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:role, :inserted_at, :updated_at]

  has_one :project, serializer: CodeCorpsWeb.ProjectView
  has_one :user, serializer: CodeCorpsWeb.UserView
end

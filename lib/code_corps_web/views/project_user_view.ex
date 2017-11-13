defmodule CodeCorpsWeb.ProjectUserView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:role, :inserted_at, :updated_at]

  has_one :project, type: "project", field: :project_id
  has_one :user, serializer: CodeCorpsWeb.UserSlimView, include: true
end

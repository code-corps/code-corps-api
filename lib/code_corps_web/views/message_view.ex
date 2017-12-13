defmodule CodeCorpsWeb.MessageView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:body, :initiated_by, :inserted_at, :subject, :updated_at]

  has_one :author, type: "user", field: :author_id
  has_one :project, type: "project", field: :project_id
end

defmodule CodeCorpsWeb.CommentView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView
  use JSONAPI.View, type: "comment"

  attributes [
    :body, :created_at, :created_from, :inserted_at, :markdown, :modified_at,
    :modified_from, :updated_at
  ]

  has_one :task, type: "task", field: :task_id
  has_one :user, type: "user", field: :user_id
end

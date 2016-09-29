defmodule CodeCorps.CommentView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :markdown, :inserted_at, :updated_at]

  has_one :user,
    field: :user_id,
    type: "user"
  has_one :task,
    field: :task_id,
    type: "task"
end

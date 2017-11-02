defmodule CodeCorpsWeb.TaskjsonapiView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JSONAPI.View, type: "task"

  def fields, do: [:archived, :body, :created_at, :created_from, :inserted_at, :markdown,
    :modified_at, :modified_from, :number, :order, :status, :title, :updated_at]

  def relationships, do: [comments: CodeCorpsWeb.CommentView]
end

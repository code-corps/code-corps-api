defmodule CodeCorps.PostView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :markdown, :number, :post_type, :status, :title, :inserted_at, :updated_at]

  has_one :project, serializer: CodeCorps.ProjectView
  has_one :user, serializer: CodeCorps.UserView

  has_many :comments, serializer: CodeCorps.CommentView
end

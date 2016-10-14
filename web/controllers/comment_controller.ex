defmodule CodeCorps.CommentController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Comment

  plug :load_and_authorize_changeset, model: Comment, only: [:create]
  plug :load_and_authorize_resource, model: Comment, only: [:update]
  plug JaResource

  def handle_create(conn, attributes) do
    %Comment{}
    |> Comment.create_changeset(attributes)
    |> Repo.insert
    |> CodeCorps.Analytics.Segment.track(:created, conn)
  end

  def handle_update(conn, comment, attributes) do
    comment
    |> Comment.changeset(attributes)
    |> Repo.update
    |> CodeCorps.Analytics.Segment.track(:edited, conn)
  end
end

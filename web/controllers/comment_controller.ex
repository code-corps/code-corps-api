defmodule CodeCorps.CommentController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.Comment

  plug :load_and_authorize_changeset, model: Comment, only: [:create]
  plug :load_and_authorize_resource, model: Comment, only: [:update]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

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

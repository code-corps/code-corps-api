defmodule CodeCorps.Web.CommentController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.Web.Comment

  plug :load_and_authorize_changeset, model: Comment, only: [:create]
  plug :load_and_authorize_resource, model: Comment, only: [:update]
  plug JaResource

  def model(), do: Comment

  @spec filter(Plug.Conn.t, Ecto.Query.t, String.t, String.t) :: Ecto.Query.t
  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  @spec handle_create(Plug.Conn.t, map) :: Ecto.Changeset.t
  def handle_create(_conn, attributes) do
    %Comment{} |> Comment.create_changeset(attributes)
  end

  @spec handle_update(Plug.Conn.t, Comment.t, map) :: Ecto.Changeset.t
  def handle_update(_conn, comment, attributes) do
    comment |> Comment.changeset(attributes)
  end
end

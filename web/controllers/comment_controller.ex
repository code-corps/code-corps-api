defmodule CodeCorps.CommentController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Comment
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, _params) do
    comments = Repo.all(Comment, preload: [:post])
    render(conn, "index.json-api", data: comments)
  end

  def create(conn, %{"data" => data = %{"type" => "comment", "attributes" => _comment_params}}) do
    changeset = Comment.create_changeset(%Comment{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, comment} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", comment_path(conn, :show, comment))
        |> render("show.json-api", data: comment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    comment = Repo.get!(Comment, id, preload: [:post])
    render(conn, "show.json-api", data: comment)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "comment", "attributes" => _comment_params}}) do
    comment = Repo.get!(Comment, id)
    changeset = Comment.changeset(comment, Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, comment} ->
        render(conn, "show.json-api", data: comment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end

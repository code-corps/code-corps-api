defmodule CodeCorps.CommentController do
  use CodeCorps.Web, :controller
  alias CodeCorps.Comment
  alias JaSerializer.Params

  @analytics Application.get_env(:code_corps, :analytics)

  plug :load_and_authorize_changeset, model: Comment, only: [:create]
  plug :load_and_authorize_resource, model: Comment, only: [:update]
  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, params = %{"task_id" => _}) do
    comments =
      Comment
      |> Comment.index_filters(params)
      |> Repo.all

    render(conn, "index.json-api", data: comments)
  end

  def create(conn, %{"data" => data = %{"type" => "comment", "attributes" => _comment_params}}) do
    changeset = Comment.create_changeset(%Comment{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, comment} ->
        conn
        |> @analytics.track(:created, comment)
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
    comment = Repo.get!(Comment, id, preload: [:task])
    render(conn, "show.json-api", data: comment)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "comment", "attributes" => _comment_params}}) do
    changeset =
      Comment
      |> Repo.get!(id)
      |> Comment.changeset(Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, comment} ->
        conn
        |> @analytics.track(:edited, comment)
        |> render("show.json-api", data: comment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end

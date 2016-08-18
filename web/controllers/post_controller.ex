defmodule CodeCorps.PostController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Post
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, %{"project_id" => project_id}) do
    posts = Repo.all(
      from c in Post,
      where: c.project_id == ^project_id,
      select: c
    )
    posts = Repo.preload(posts, [:project])
    render(conn, "index.json-api", data: posts)
  end
  def index(conn, _params) do
    posts = Repo.all(Post)
    render(conn, "index.json-api", data: posts)
  end

  def create(conn, %{"data" => data = %{"type" => "post", "attributes" => _post_params}}) do
    changeset = Post.create_changeset(%Post{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, post} ->
        post = Repo.preload(post, [:project])
        conn
        |> put_status(:created)
        |> put_resp_header("location", post_path(conn, :show, post))
        |> render("show.json-api", data: post)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => number, "project_id" => project_id}) do
    post = Repo.one(
      from c in Post,
      where: c.number == ^number,
      where: c.project_id == ^project_id,
      select: c
    )
    post = Repo.preload(post, [:project])
    render(conn, "show.json-api", data: post)
  end
  def show(conn, %{"id" => id}) do
    post = 
      Post
      |> preload([:project])
      |> Repo.get!(id)
    render(conn, "show.json-api", data: post)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "post", "attributes" => _post_params}}) do
    post = 
      Post
      |> preload([:project])
      |> Repo.get!(id)
    changeset = Post.changeset(post, Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, post} ->
        render(conn, "show.json-api", data: post)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end

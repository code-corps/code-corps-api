defmodule CodeCorps.PostController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Post
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: Post, only: [:create, :update]
  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, params) do
    posts =
      Post
      |> preload([:comments, :project, :user])
      |> Post.index_filters(params)
      |> Repo.paginate(params["page"])

    meta = %{
      current_page: posts.page_number,
      page_size: posts.page_size,
      total_pages: posts.total_pages,
      total_records: posts.total_entries
    }

    render(conn, "index.json-api", data: posts, opts: [meta: meta])
  end

  def create(conn, %{"data" => data = %{"type" => "post", "attributes" => _post_params}}) do
    changeset = Post.create_changeset(%Post{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, post} ->
        post = Repo.preload(post, [:comments, :project, :user])

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

  def show(conn, params = %{"project_id" => _project_id, "id" => _number}) do
    post =
      Post
      |> preload([:comments, :project, :user])
      |> Post.show_project_post_filters(params)
      |> Repo.one!
    render(conn, "show.json-api", data: post)
  end
  def show(conn, %{"id" => id}) do
    post =
      Post
      |> preload([:comments, :project, :user])
      |> Repo.get!(id)
    render(conn, "show.json-api", data: post)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "post", "attributes" => _post_params}}) do
    changeset =
      Post
      |> preload([:comments, :project, :user])
      |> Repo.get!(id)
      |> Post.changeset(Params.to_attributes(data))

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

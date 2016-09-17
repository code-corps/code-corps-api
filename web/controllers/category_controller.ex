defmodule CodeCorps.CategoryController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Category
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: Category, only: [:create, :update]

  def index(conn, _params) do
    categories = Category |> Repo.all |> Repo.preload([:project_categories, :projects])
    render(conn, "index.json-api", data: categories)
  end

  def create(conn, %{"data" => data = %{"type" => "category", "attributes" => _category_params}}) do
    changeset = Category.create_changeset(%Category{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, category} ->
        category =
          category
          |> Repo.preload([:projects])

        conn
        |> put_status(:created)
        |> put_resp_header("location", category_path(conn, :show, category))
        |> render("show.json-api", data: category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    category =
      Category
      |> preload([:projects])
      |> Repo.get!(id)

    render(conn, "show.json-api", data: category)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "category", "attributes" => _category_params}}) do
    changeset =
      Category
      |> preload([:projects])
      |> Repo.get!(id)
      |> Category.changeset(Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, category} ->
        render(conn, "show.json-api", data: category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end

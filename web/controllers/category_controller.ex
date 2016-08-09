defmodule CodeCorps.CategoryController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Category
  alias JaSerializer.Params

  def index(conn, _params) do
    categories = Repo.all(Category)
    render(conn, "index.json-api", data: categories)
  end

  def create(conn, %{"data" => data = %{"type" => "category", "attributes" => _category_params}}) do
    changeset = Category.changeset(%Category{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, category} ->
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
    category = Repo.get!(Category, id)
    render(conn, "show.json-api", data: category)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "category", "attributes" => _category_params}}) do
    category = Repo.get!(Category, id)
    changeset = Category.changeset(category, Params.to_attributes(data))
    
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

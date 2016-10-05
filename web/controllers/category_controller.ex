defmodule CodeCorps.CategoryController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Category
  alias JaSerializer.Params

  plug :load_resource, model: Category, only: [:show]
  plug :load_and_authorize_resource, model: Category, only: [:create, :update]

  def index(conn, _params) do
    categories = Category |> Repo.all
    render(conn, "index.json-api", data: categories)
  end

  def create(conn, %{"data" => data = %{"type" => "category", "attributes" => _category_params}}) do
    changeset = Category.create_changeset(%Category{}, Params.to_attributes(data))

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

  def show(conn, %{"id" => _id}) do
    render(conn, "show.json-api", data: conn.assigns.category)
  end

  def update(conn, %{"id" => _id, "data" => data = %{"type" => "category", "attributes" => _category_params}}) do
    changeset = conn.assigns.category |> Category.changeset(Params.to_attributes(data))

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

defmodule CodeCorps.ProjectCategoryController do
  use CodeCorps.Web, :controller

  import CodeCorps.ControllerHelpers

  alias CodeCorps.ProjectCategory

  plug :load_resource, model: ProjectCategory, only: [:show], preload: [:project, :category]
  plug :load_and_authorize_changeset, model: ProjectCategory, only: [:create]
  plug :load_and_authorize_resource, model: ProjectCategory, only: [:delete]
  plug :scrub_params, "data" when action in [:create]

  def index(conn, params) do
    project_categories =
      case params do
        %{"filter" => %{"id" => id_list}} ->
          ids = id_list |> coalesce_id_string
          ProjectCategory
          |> where([p], p.id in ^ids)
          |> Repo.all
        %{} ->
          ProjectCategory
          |> Repo.all
      end
    render(conn, "index.json-api", data: project_categories)
  end

  def create(conn, %{"data" => %{"type" => "project-category"}}) do
    case Repo.insert(conn.assigns.changeset) do
      {:ok, project_category} ->
        conn
        |> put_status(:created)
        |> render("show.json-api", data: project_category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id}) do
    render(conn, "show.json-api", data: conn.assigns.project_category)
  end

  def delete(conn, %{"id" => _id}) do
    conn.assigns.project_category |> Repo.delete!

    conn |> send_resp(:no_content, "")
  end
end

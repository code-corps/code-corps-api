defmodule CodeCorps.ProjectCategoryController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.ProjectCategory

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  plug :load_resource, model: ProjectCategory, only: [:show], preload: [:project, :category]
  plug :load_and_authorize_changeset, model: ProjectCategory, only: [:create]
  plug :load_and_authorize_resource, model: ProjectCategory, only: [:delete]
  plug JaResource, except: [:create]

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
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
end

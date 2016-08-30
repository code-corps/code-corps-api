defmodule CodeCorps.ProjectCategoryController do
  use CodeCorps.Web, :controller

  alias JaSerializer.Params
  alias CodeCorps.ProjectCategory

  plug :load_and_authorize_resource, model: ProjectCategory, only: [:create, :delete]
  plug :scrub_params, "data" when action in [:create]

  def create(conn, %{"data" => data = %{"type" => "project-category"}}) do
    changeset = %ProjectCategory{} |> ProjectCategory.create_changeset(Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, project_category} ->
        project_category = project_category |> Repo.preload([:project, :category])

        conn
        |> put_status(:created)
        |> render("show.json-api", data: project_category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ProjectCategory |> Repo.get!(id) |> Repo.delete!

    conn |> send_resp(:no_content, "")
  end
end

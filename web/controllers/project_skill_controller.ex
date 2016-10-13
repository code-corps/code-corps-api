defmodule CodeCorps.ProjectSkillController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.ProjectSkill

  plug :load_resource, model: ProjectSkill, only: [:show], preload: [:project, :skill]
  plug :load_and_authorize_changeset, model: ProjectSkill, only: [:create]
  plug :load_and_authorize_resource, model: ProjectSkill, only: [:delete]
  plug JaResource, except: [:create]

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def create(conn, %{"data" => %{"type" => "project-skill", "attributes" => _project_skill_params}}) do
    case Repo.insert(conn.assigns.changeset) do
      {:ok, project_skill} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", project_skill_path(conn, :show, project_skill))
        |> render("show.json-api", data: project_skill)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end

defmodule CodeCorps.ProjectSkillController do
  use CodeCorps.Web, :controller

  import CodeCorps.ControllerHelpers

  alias CodeCorps.ProjectSkill

  plug :load_resource, model: ProjectSkill, only: [:show], preload: [:project, :skill]
  plug :load_and_authorize_changeset, model: ProjectSkill, only: [:create]
  plug :load_and_authorize_resource, model: ProjectSkill, only: [:delete]
  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, params) do
    project_skills =
      case params do
        %{"filter" => %{"id" => id_list}} ->
          ids = id_list |> coalesce_id_string
          ProjectSkill
          |> where([p], p.id in ^ids)
          |> Repo.all
        %{} ->
          ProjectSkill
          |> Repo.all
      end
    render(conn, "index.json-api", data: project_skills)
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

  def show(conn, %{"id" => _id}) do
    render(conn, "show.json-api", data: conn.assigns.project_skill)
  end

  def delete(conn, %{"id" => _id}) do
    conn.assigns.project_skill |> Repo.delete!

    send_resp(conn, :no_content, "")
  end

end

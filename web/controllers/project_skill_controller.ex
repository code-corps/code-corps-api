defmodule CodeCorps.ProjectSkillController do
  use CodeCorps.Web, :controller

  import CodeCorps.ControllerHelpers

  alias CodeCorps.ProjectSkill
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: ProjectSkill, only: [:create, :delete]
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

  def create(conn, %{"data" => data = %{"type" => "project-skill", "attributes" => _project_skill_params}}) do
    changeset = ProjectSkill.changeset(%ProjectSkill{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
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

  def show(conn, %{"id" => id}) do
    project_skill =
      ProjectSkill
      |> Repo.get!(id)
    render(conn, "show.json-api", data: project_skill)
  end

  def delete(conn, %{"id" => id}) do
    project_skill = Repo.get!(ProjectSkill, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(project_skill)

    send_resp(conn, :no_content, "")
  end

end

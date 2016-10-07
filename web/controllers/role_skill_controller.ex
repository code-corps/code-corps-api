defmodule CodeCorps.RoleSkillController do
  use CodeCorps.Web, :controller

  alias CodeCorps.RoleSkill
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: RoleSkill, only: [:create, :delete]
  plug :scrub_params, "data" when action in [:create]

  def index(conn, params) do
    role_skills =
      RoleSkill
      |> RoleSkill.index_filters(params)
      |> Repo.all
    render(conn, "index.json-api", data: role_skills)
  end

  def create(conn, %{"data" => data = %{"type" => "role-skill", "attributes" => _role_skill_params}}) do
    changeset = RoleSkill.changeset(%RoleSkill{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, role_skill} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", role_skill_path(conn, :show, role_skill))
        |> render("show.json-api", data: role_skill)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    role_skill =
      RoleSkill
      |> Repo.get!(id)
    render(conn, "show.json-api", data: role_skill)
  end

  def delete(conn, %{"id" => id}) do
    role_skill = Repo.get!(RoleSkill, id)
    Repo.delete!(role_skill)

    send_resp(conn, :no_content, "")
  end

end

defmodule CodeCorps.RoleSkillController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.RoleSkill
  alias JaSerializer.Params

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  plug :load_and_authorize_resource, model: RoleSkill, only: [:create, :delete]
  plug :scrub_params, "data" when action in [:create]
  plug JaResource, except: [:create]

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
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
end

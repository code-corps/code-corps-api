defmodule CodeCorps.SkillController do
  use CodeCorps.Web, :controller
  alias CodeCorps.Skill
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: Skill, only: [:create]
  plug :scrub_params, "data" when action in [:create]

  def index(conn, params) do
    skills =
      Skill
      |> Skill.index_filters(params)
      |> Repo.all
      |> Repo.preload([:role_skills])

    render(conn, "index.json-api", data: skills)
  end

  def create(conn, %{"data" => data = %{"type" => "skill", "attributes" => _skill_params}}) do
    changeset = Skill.changeset(%Skill{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, skill} ->
        skill = Repo.preload(skill, [:role_skills])

        conn
        |> put_status(:created)
        |> put_resp_header("location", skill_path(conn, :show, skill))
        |> render("show.json-api", data: skill)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    skill =
      Skill
      |> Repo.get!(id)
      |> Repo.preload([:role_skills])
    render(conn, "show.json-api", data: skill)
  end
end

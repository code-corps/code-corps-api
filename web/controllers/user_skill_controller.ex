defmodule CodeCorps.UserSkillController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller

  import CodeCorps.AuthenticationHelpers, only: [authorize: 2, authorized?: 1]

  alias CodeCorps.UserSkill
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: UserSkill, only: [:delete]
  plug :scrub_params, "data" when action in [:create]

  def index(conn, params) do
    user_skills =
      UserSkill
      |> UserSkill.index_filters(params)
      |> Repo.all

    render(conn, "index.json-api", data: user_skills)
  end

  def create(conn, %{"data" => data = %{"type" => "user-skill"}}) do
    changeset = UserSkill.changeset(%UserSkill{}, Params.to_attributes(data))

    conn = conn |> authorize(changeset)

    if conn |> authorized? do
      case Repo.insert(changeset) do
        {:ok, user_skill} ->
          conn
          |> @analytics.track(:added, user_skill)
          |> put_status(:created)
          |> put_resp_header("location", user_skill_path(conn, :show, user_skill))
          |> render("show.json-api", data: user_skill)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
      end
    else
      conn
    end
  end

  def show(conn, %{"id" => id}) do
    user_skill =
      UserSkill
      |> Repo.get!(id)
    render(conn, "show.json-api", data: user_skill)
  end

  def delete(conn, %{"id" => id}) do
    user_skill =
      UserSkill
      |> Repo.get!(id)
      |> Repo.delete!

    conn
    |> @analytics.track(:removed, user_skill)
    |> send_resp(:no_content, "")
  end
end

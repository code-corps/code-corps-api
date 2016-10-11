defmodule CodeCorps.UserSkillController do
  use CodeCorps.Web, :controller
  alias CodeCorps.UserSkill

  @analytics Application.get_env(:code_corps, :analytics)

  plug :load_resource, model: UserSkill, only: [:show], preload: [:user, :skill]
  plug :load_and_authorize_changeset, model: UserSkill, only: [:create]
  plug :load_and_authorize_resource, model: UserSkill, only: [:delete]
  plug :scrub_params, "data" when action in [:create]

  def index(conn, params) do
    user_skills =
      UserSkill
      |> UserSkill.index_filters(params)
      |> Repo.all

    render(conn, "index.json-api", data: user_skills)
  end

  def create(conn, %{"data" => %{"type" => "user-skill"}}) do
    case Repo.insert(conn.assigns.changeset) do
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
  end

  def show(conn, %{"id" => _id}) do
    render(conn, "show.json-api", data: conn.assigns.user_skill)
  end

  def delete(conn, %{"id" => _id}) do
    conn.assigns.user_skill |> Repo.delete!

    conn
    |> @analytics.track(:removed, conn.assigns.user_skill)
    |> send_resp(:no_content, "")
  end
end

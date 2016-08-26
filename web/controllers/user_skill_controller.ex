defmodule CodeCorps.UserSkillController do
  use CodeCorps.Web, :controller

  alias CodeCorps.UserSkill
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create]

  def index(conn, params) do
    user_skills =
      UserSkill
      |> UserSkill.index_filters(params)
      |> preload([:user, :skill])
      |> Repo.all

    render(conn, "index.json-api", data: user_skills)
  end

  def create(conn, %{"data" => data = %{"type" => "user-skill"}}) do
    changeset = UserSkill.changeset(%UserSkill{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, user_skill} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_skill_path(conn, :show, user_skill))
        |> render("show.json-api", data: user_skill |> Repo.preload([:user, :skill]))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_skill =
      UserSkill
      |> preload([:user, :skill])
      |> Repo.get!(id)
    render(conn, "show.json-api", data: user_skill)
  end

  def delete(conn, %{"id" => id}) do
    UserSkill |> Repo.get!(id) |> Repo.delete!
    conn |> send_resp(:no_content, "")
  end
end

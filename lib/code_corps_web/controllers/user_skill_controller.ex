defmodule CodeCorpsWeb.UserSkillController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{UserSkill, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with user_skills <- UserSkill |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: user_skills)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %UserSkill{} = user_skill <- UserSkill |> Repo.get(id) do
      conn |> render("show.json-api", data: user_skill)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:create, %UserSkill{}, params),
      {:ok, %UserSkill{} = user_skill} <- %UserSkill{} |> UserSkill.create_changeset(params) |> Repo.insert
    do
      conn |> put_status(:created) |> render("show.json-api", data: user_skill)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %UserSkill{} = user_skill <- UserSkill |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:delete, user_skill),
      {:ok, %UserSkill{} = _user_skill} <- user_skill |> Repo.delete
    do
      conn |> Conn.assign(:user_skill, user_skill) |> send_resp(:no_content, "")
    end
  end
end

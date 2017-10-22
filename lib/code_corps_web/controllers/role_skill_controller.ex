defmodule CodeCorpsWeb.RoleSkillController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{RoleSkill, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with role_skills <- RoleSkill |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: role_skills)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %RoleSkill{} = role_skill <- RoleSkill |> Repo.get(id) do
      conn |> render("show.json-api", data: role_skill)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:create, %RoleSkill{}, params),
      {:ok, %RoleSkill{} = role_skill} <- %RoleSkill{} |> RoleSkill.create_changeset(params) |> Repo.insert
    do
      conn |> put_status(:created) |> render("show.json-api", data: role_skill)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %RoleSkill{} = role_skill <- RoleSkill |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:delete, role_skill),
      {:ok, %RoleSkill{} = _role_skill} <- role_skill |> Repo.delete
    do
      conn |> Conn.assign(:role_skill, role_skill) |> send_resp(:no_content, "")
    end
  end
end

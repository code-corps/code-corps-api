defmodule CodeCorpsWeb.RoleController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Role, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    roles = Role |> Query.id_filter(params) |> Repo.all |> preload()
    conn |> render("index.json-api", data: roles)
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %Role{} = role <- Role |> Repo.get(id) |> preload() do
      conn |> render("show.json-api", data: role)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Role{}, params),
         {:ok, %Role{} = role} <- %Role{} |> Role.changeset(params) |> Repo.insert,
         role = preload(role)
    do
      conn |> put_status(:created) |> render("show.json-api", data: role)
    end
  end

  @preloads [:role_skills]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end

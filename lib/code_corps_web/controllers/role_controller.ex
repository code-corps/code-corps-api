defmodule CodeCorpsWeb.RoleController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Role, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with roles <- Role |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: roles)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %Role{} = role <- Role |> Repo.get(id) do
      conn |> render("show.json-api", data: role)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Role{}, params),
         {:ok, %Role{} = role} <- %Role{} |> Role.changeset(params) |> Repo.insert do
      conn |> put_status(:created) |> render("show.json-api", data: role)
    end
  end
end

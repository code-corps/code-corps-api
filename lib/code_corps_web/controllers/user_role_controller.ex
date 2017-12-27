defmodule CodeCorpsWeb.UserRoleController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{UserRole, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with user_roles <- UserRole |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: user_roles)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %UserRole{} = user_role <- UserRole |> Repo.get(id) do
      conn |> render("show.json-api", data: user_role)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %UserRole{}, params),
         {:ok, %UserRole{} = user_role} <- %UserRole{} |> UserRole.create_changeset(params) |> Repo.insert do
      conn |> put_status(:created) |> render("show.json-api", data: user_role)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %UserRole{} = user_role <- UserRole |> Repo.get(id),
      %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:delete, user_role),
      {:ok, %UserRole{} = _user_role} <- user_role |> Repo.delete
    do
      conn |> Conn.assign(:user_role, user_role) |> send_resp(:no_content, "")
    end
  end
end

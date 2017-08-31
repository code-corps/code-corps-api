defmodule CodeCorpsWeb.CategoryController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{ Category, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with categories <- Category |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: categories)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %Category{} = category <- Category |> Repo.get(id) do
      conn |> render("show.json-api", data: category)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Category{}, params),
      {:ok, %Category{} = category} <- %Category{} |> Category.create_changeset(params) |> Repo.insert
    do
      conn |> put_status(:created) |> render("show.json-api", data: category)
    end
  end

  @spec update(Plug.Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %Category{} = category <- Category |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:update, category),
      {:ok, %Category{} = category} <- category |> Category.changeset(params) |> Repo.update
    do
      conn |> render("show.json-api", data: category)
    end
  end
end

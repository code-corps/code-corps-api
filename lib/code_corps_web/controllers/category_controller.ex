defmodule CodeCorpsWeb.CategoryController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Category, Repo, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    categories = Category |> Query.id_filter(params) |> Repo.all |> preload()
    conn |> render("index.json-api", data: categories)
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %Category{} = category <- Category |> Repo.get(id) |> preload() do
      conn |> render(CodeCorpsWeb.CategoryView, "show.json-api", %{ data: category, conn: conn, params: id })
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Category{}, params),
      {:ok, %Category{} = category} <- %Category{} |> Category.create_changeset(params) |> Repo.insert,
      category <- preload(category)
    do
      conn |> put_status(:created) |> render("show.json-api", data: category)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %Category{} = category <- Category |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:update, category),
      {:ok, %Category{} = category} <- category |> Category.changeset(params) |> Repo.update,
      category <- preload(category)
    do
      conn |> render("show.json-api", data: category)
    end
  end

  @preloads [:project_categories]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end

defmodule CodeCorpsWeb.ProjectCategoryController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{ProjectCategory, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with project_categories <- ProjectCategory |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: project_categories)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %ProjectCategory{} = project_category <- ProjectCategory |> Repo.get(id) do
      conn |> render("show.json-api", data: project_category)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %ProjectCategory{}, params),
         {:ok, %ProjectCategory{} = project_category} <- %ProjectCategory{} |> ProjectCategory.create_changeset(params) |> Repo.insert do
      conn |> put_status(:created) |> render("show.json-api", data: project_category)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %ProjectCategory{} = project_category <- ProjectCategory |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:delete, project_category),
      {:ok, %ProjectCategory{} = _project_category} <- project_category |> Repo.delete
    do
      conn |> Conn.assign(:project_category, project_category) |> send_resp(:no_content, "")
    end
  end
end

defmodule CodeCorpsWeb.UserCategoryController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{UserCategory, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with user_categories <- UserCategory |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: user_categories)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %UserCategory{} = user_category <- UserCategory |> Repo.get(id) do
      conn |> render("show.json-api", data: user_category)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:create, %UserCategory{}, params),
      {:ok, %UserCategory{} = user_category} <- %UserCategory{} |> UserCategory.create_changeset(params) |> Repo.insert
    do
      conn |> put_status(:created) |> render("show.json-api", data: user_category)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %UserCategory{} = user_category <- UserCategory |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:delete, user_category),
      {:ok, %UserCategory{} = _user_category} <- user_category |> Repo.delete
    do
      conn |> Conn.assign(:user_category, user_category) |> send_resp(:no_content, "")
    end
  end
end

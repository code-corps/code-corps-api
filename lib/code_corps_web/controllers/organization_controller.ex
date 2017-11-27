defmodule CodeCorpsWeb.OrganizationController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Helpers.Query, Organization, Organizations, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    organizations =
      Organization
      |> Query.id_filter(params)
      |> Repo.all
      |> preload()

    conn |> render("index.json-api", data: organizations)
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %Organization{} = organization <- Organization |> Repo.get(id) |> preload()
    do
      conn |> render("show.json-api", data: organization)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Organization{}, params),
         {:ok, %Organization{} = organization} <- Organizations.create(params),
         organization <- preload(organization)
    do
      conn |> put_status(:created) |> render("show.json-api", data: organization)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %Organization{} = organization <- Organization |> Repo.get(id),
      %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:update, organization),
      {:ok, %Organization{} = organization} <- organization |> Organization.changeset(params) |> Repo.update,
      organization <- preload(organization)
    do
        conn |> render("show.json-api", data: organization)
    end
  end

  @preloads [:organization_github_app_installations, :projects, :slugged_route, :stripe_connect_account]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end

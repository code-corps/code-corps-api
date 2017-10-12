defmodule CodeCorpsWeb.GithubAppInstallationController do
  use CodeCorpsWeb, :controller

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.{GithubAppInstallation, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with installations <- GithubAppInstallation |> id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: installations)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %GithubAppInstallation{} = installation <- GithubAppInstallation |> Repo.get(id) do
      conn |> render("show.json-api", data: installation)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %GithubAppInstallation{}, params),
         {:ok, %GithubAppInstallation{} = installation} <- %GithubAppInstallation{} |> GithubAppInstallation.create_changeset(params) |> Repo.insert do
      conn |> put_status(:created) |> render("show.json-api", data: installation)
    end
  end
end

defmodule CodeCorpsWeb.OrganizationGithubAppInstallationController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{OrganizationGithubAppInstallation, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with organization_installations <- OrganizationGithubAppInstallation |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: organization_installations)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %OrganizationGithubAppInstallation{} = organization_installation <- OrganizationGithubAppInstallation |> Repo.get(id) do
      conn |> render("show.json-api", data: organization_installation)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %OrganizationGithubAppInstallation{}, params),
         {:ok, %OrganizationGithubAppInstallation{} = organization_installation} <- %OrganizationGithubAppInstallation{} |> OrganizationGithubAppInstallation.create_changeset(params) |> Repo.insert do
      conn |> put_status(:created) |> render("show.json-api", data: organization_installation)
    end
  end

  @spec delete(Plug.Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = params) do
    with %OrganizationGithubAppInstallation{} = organization_github_installation <- OrganizationGithubAppInstallation |> Repo.get(id),
         %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:delete, organization_github_installation, params),
         {:ok, _organization_github_installation} <-
           organization_github_installation
           |> Repo.delete do
      conn |> send_resp(:no_content, "")
    end
  end
end

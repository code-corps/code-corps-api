defmodule CodeCorps.OrganizationGithubAppInstallationController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.{OrganizationGithubAppInstallation}

  @preloads [:github_app_installation, :organization]

  plug :load_resource, model: OrganizationGithubAppInstallation, only: [:show], preload: @preloads
  plug :load_and_authorize_changeset, model: OrganizationGithubAppInstallation, only: [:create], preload: @preloads
  plug :load_and_authorize_resource, model: OrganizationGithubAppInstallation, only: [:delete]

  plug JaResource


  @spec filter(Plug.Conn.t, Ecto.Query.t, String.t, String.t) :: Ecto.Query.t
  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  @spec handle_create(Plug.Conn.t, map) :: Ecto.Changeset.t
  def handle_create(_conn, attributes) do
    %OrganizationGithubAppInstallation{}
    |> OrganizationGithubAppInstallation.create_changeset(attributes)
  end
end

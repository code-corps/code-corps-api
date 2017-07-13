defmodule CodeCorps.GithubAppInstallationController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.{GithubAppInstallation}

  @preloads [:project, :user]

  plug :load_resource, model: GithubAppInstallation, only: [:show], preload: @preloads
  plug :load_and_authorize_changeset, model: GithubAppInstallation, only: [:create], preload: @preloads

  plug JaResource

  @spec filter(Plug.Conn.t, Ecto.Query.t, String.t, String.t) :: Ecto.Query.t
  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  @spec handle_create(Plug.Conn.t, map) :: Ecto.Changeset.t
  def handle_create(_conn, attributes) do
    %GithubAppInstallation{}
    |> GithubAppInstallation.create_changeset(attributes)
  end
end

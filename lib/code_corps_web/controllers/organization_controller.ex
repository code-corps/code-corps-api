defmodule CodeCorpsWeb.OrganizationController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.Organization

  plug :load_and_authorize_resource, model: Organization, only: [:create, :update]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.Organization

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(_conn, attributes) do
    Organization.create_changeset(%Organization{}, attributes)
  end
end

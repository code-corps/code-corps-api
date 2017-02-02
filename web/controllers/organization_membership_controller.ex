defmodule CodeCorps.OrganizationMembershipController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.OrganizationMembership

  plug :load_resource, model: OrganizationMembership, only: [:show], preload: [:organization, :member]
  plug :load_and_authorize_resource, model: OrganizationMembership, only: [:delete]
  plug :load_and_authorize_changeset, model: OrganizationMembership, only: [:create, :update], preload: [:organization, :member]
  plug JaResource

  @spec filter(Plug.Conn.t, Ecto.Query.t, String.t, String.t) :: Ecto.Query.t
  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  @spec handle_create(Plug.Conn.t, map) :: Ecto.Changeset.t
  def handle_create(_conn, attributes) do
    %OrganizationMembership{} |> OrganizationMembership.create_changeset(attributes)
  end

  @spec handle_update(Plug.Conn.t, OrganizationMembership.t, map) :: Ecto.Changeset.t
  def handle_update(_conn, model, attributes) do
    model |> OrganizationMembership.update_changeset(attributes)
  end
end

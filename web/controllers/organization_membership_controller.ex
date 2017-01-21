defmodule CodeCorps.OrganizationMembershipController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.OrganizationMembership

  plug :load_resource, model: OrganizationMembership, only: [:show], preload: [:organization, :member]
  plug :load_and_authorize_resource, model: OrganizationMembership, only: [:delete]
  plug :load_and_authorize_changeset, model: OrganizationMembership, only: [:create, :update], preload: [:organization, :member]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(conn, attributes) do
    %OrganizationMembership{}
    |> OrganizationMembership.create_changeset(attributes)
    |> Repo.insert
    |> CodeCorps.Analytics.Segment.track(:created, conn)
  end

  def handle_update(conn, model, attributes) do
    model
    |> OrganizationMembership.update_changeset(attributes)
    |> Repo.update
    |> CodeCorps.Analytics.Segment.track(:edited, conn)
  end
end

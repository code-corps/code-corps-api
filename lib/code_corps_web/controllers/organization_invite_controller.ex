defmodule CodeCorpsWeb.OrganizationInviteController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.OrganizationInvite

  plug :load_and_authorize_resource, model: OrganizationInvite, only: [:create, :update]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.OrganizationInvite

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(_conn, attributes) do
    OrganizationInvite.create_changeset(%OrganizationInvite{}, attributes)
  end
end

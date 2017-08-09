defmodule CodeCorpsWeb.UserRoleController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.UserRole

  plug :load_resource, model: UserRole, only: [:show], preload: [:user, :role]
  plug :load_and_authorize_changeset, model: UserRole, only: [:create]
  plug :load_and_authorize_resource, model: UserRole, only: [:delete]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.UserRole

  @spec filter(Plug.Conn.t, Ecto.Query.t, String.t, String.t) :: Ecto.Query.t
  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  @spec handle_create(Plug.Conn.t, map) :: Ecto.Changeset.t
  def handle_create(_conn, attributes) do
    %UserRole{} |> UserRole.create_changeset(attributes)
  end

end

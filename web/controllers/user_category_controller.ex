defmodule CodeCorps.UserCategoryController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.UserCategory

  plug :load_resource, model: UserCategory, only: [:show], preload: [:user, :category]
  plug :load_and_authorize_changeset, model: UserCategory, only: [:create]
  plug :load_and_authorize_resource, model: UserCategory, only: [:delete]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  @spec handle_create(Plug.Conn.t, map) :: Ecto.Changeset.t
  def handle_create(_conn, attributes) do
    %UserCategory{} |> UserCategory.create_changeset(attributes)
  end
end

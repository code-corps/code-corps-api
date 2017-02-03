defmodule CodeCorps.UserSkillController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.UserSkill

  plug :load_resource, model: UserSkill, only: [:show], preload: [:user, :skill]
  plug :load_and_authorize_changeset, model: UserSkill, only: [:create]
  plug :load_and_authorize_resource, model: UserSkill, only: [:delete]
  plug JaResource

  @spec filter(Plug.Conn.t, Ecto.Query.t, String.t, String.t) :: Ecto.Query.t
  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(conn, attributes) do
    %UserSkill{}
    |> UserSkill.create_changeset(attributes)
    |> Repo.insert
    |> CodeCorps.Analytics.Segment.track(:created, conn)
  end

  def handle_delete(conn, record) do
    record
    |> Repo.delete
    |> CodeCorps.Analytics.Segment.track(:deleted, conn)
  end
end

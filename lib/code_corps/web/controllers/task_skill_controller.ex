defmodule CodeCorps.Web.TaskSkillController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.Web.TaskSkill

  plug :load_resource, model: TaskSkill, only: [:show], preload: [:task, :skill]
  plug :load_and_authorize_changeset, model: TaskSkill, only: [:create]
  plug :load_and_authorize_resource, model: TaskSkill, only: [:delete]
  plug JaResource

  @spec filter(Plug.Conn.t, Ecto.Query.t, String.t, String.t) :: Plug.Conn.t
  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  @spec handle_create(Plug.Conn.t, map) :: Ecto.Changeset.t
  def handle_create(_conn, attributes) do
    %TaskSkill{} |> TaskSkill.create_changeset(attributes)
  end
end

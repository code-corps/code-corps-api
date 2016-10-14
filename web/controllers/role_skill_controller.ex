defmodule CodeCorps.RoleSkillController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.RoleSkill
  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.RoleSkill

  plug :load_and_authorize_resource, model: RoleSkill, only: [:create, :delete]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end
end

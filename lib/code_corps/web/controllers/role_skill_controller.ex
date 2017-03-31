defmodule CodeCorps.Web.RoleSkillController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Web.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.Web.RoleSkill

  plug :load_and_authorize_resource, model: RoleSkill, only: [:create, :delete]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end
end

defmodule CodeCorps.Web.SkillController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Web.Helpers.Query, only: [id_filter: 2, title_filter: 2, limit_filter: 2]

  alias CodeCorps.Web.Skill

  plug :load_and_authorize_resource, model: Skill, only: [:create]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_index(_conn, params) do
    Skill
    |> title_filter(params)
    |> limit_filter(params)
  end
end

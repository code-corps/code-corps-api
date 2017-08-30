defmodule CodeCorpsWeb.SkillController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2, title_filter: 2, limit_filter: 2]

  alias CodeCorps.Skill

  plug :load_and_authorize_resource, model: Skill, only: [:create]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.Skill

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_index(_conn, params) do
    Skill
    |> title_filter(params)
    |> limit_filter(params)
  end
end

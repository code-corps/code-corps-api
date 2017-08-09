defmodule CodeCorpsWeb.RoleSkillController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.RoleSkill

  plug :load_and_authorize_resource, model: RoleSkill, only: [:create, :delete]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.RoleSkill

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end
end

defmodule CodeCorpsWeb.ProjectSkillController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.ProjectSkill

  plug :load_resource, model: ProjectSkill, only: [:show], preload: [:project, :skill]
  plug :load_and_authorize_changeset, model: ProjectSkill, only: [:create]
  plug :load_and_authorize_resource, model: ProjectSkill, only: [:delete]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.ProjectSkill

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(_conn, attributes) do
    %ProjectSkill{} |> ProjectSkill.create_changeset(attributes)
  end
end

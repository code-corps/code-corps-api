defmodule CodeCorps.Web.ProjectSkillController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Web.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.Web.ProjectSkill

  plug :load_resource, model: ProjectSkill, only: [:show], preload: [:project, :skill]
  plug :load_and_authorize_changeset, model: ProjectSkill, only: [:create]
  plug :load_and_authorize_resource, model: ProjectSkill, only: [:delete]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(_conn, attributes) do
    %ProjectSkill{} |> ProjectSkill.create_changeset(attributes)
  end
end

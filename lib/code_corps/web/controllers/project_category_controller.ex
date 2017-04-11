defmodule CodeCorps.Web.ProjectCategoryController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Web.ProjectCategory

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  plug :load_resource, model: ProjectCategory, only: [:show], preload: [:project, :category]
  plug :load_and_authorize_changeset, model: ProjectCategory, only: [:create]
  plug :load_and_authorize_resource, model: ProjectCategory, only: [:delete]
  plug JaResource

  def model(), do: ProjectCategory

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(_conn, attributes) do
    %ProjectCategory{} |> ProjectCategory.create_changeset(attributes)
  end
end

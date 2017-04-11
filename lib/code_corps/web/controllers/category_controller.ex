defmodule CodeCorps.Web.CategoryController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Web.Category

  plug :load_resource, model: Category, only: [:show]
  plug :load_and_authorize_resource, model: Category, only: [:create, :update]
  plug JaResource

  def model(), do: Category

  def handle_create(_conn, attributes) do
    Category.create_changeset(%Category{}, attributes)
  end
end

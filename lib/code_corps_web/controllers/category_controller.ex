defmodule CodeCorpsWeb.CategoryController do
  use CodeCorpsWeb, :controller
  use JaResource

  alias CodeCorps.Category

  plug :load_resource, model: Category, only: [:show]
  plug :load_and_authorize_resource, model: Category, only: [:create, :update]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.Category

  def handle_create(_conn, attributes) do
    Category.create_changeset(%Category{}, attributes)
  end
end

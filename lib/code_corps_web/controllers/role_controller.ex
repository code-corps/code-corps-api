defmodule CodeCorpsWeb.RoleController do
  use CodeCorpsWeb, :controller
  use JaResource

  alias CodeCorps.Role

  plug :load_and_authorize_resource, model: Role, only: [:create]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.Role
end

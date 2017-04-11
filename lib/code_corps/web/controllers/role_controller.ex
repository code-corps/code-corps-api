defmodule CodeCorps.Web.RoleController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Web.Role

  plug :load_and_authorize_resource, model: Role, only: [:create]
  plug JaResource

  def model(), do: Role
end

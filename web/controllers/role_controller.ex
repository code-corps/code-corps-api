defmodule CodeCorps.RoleController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Role

  plug :load_and_authorize_resource, model: Role, only: [:create]
  plug JaResource
end

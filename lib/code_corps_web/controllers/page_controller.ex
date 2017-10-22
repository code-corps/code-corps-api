defmodule CodeCorpsWeb.PageController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  def index(conn, _params) do
    redirect conn, external: "http://docs.codecorpsapi.apiary.io/"
  end
end

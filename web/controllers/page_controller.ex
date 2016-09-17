defmodule CodeCorps.PageController do
  use CodeCorps.Web, :controller

  def index(conn, _params) do
    redirect conn, external: "http://docs.codecorpsapi.apiary.io/"
  end
end

defmodule CodeCorpsWeb.PageController do
  use CodeCorpsWeb, :controller

  def index(conn, _params) do
    redirect conn, external: "http://docs.codecorpsapi.apiary.io/"
  end
end

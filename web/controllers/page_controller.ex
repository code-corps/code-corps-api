defmodule CodeCorps.PageController do
  use CodeCorps.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

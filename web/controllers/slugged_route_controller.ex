defmodule CodeCorps.SluggedRouteController do
  use CodeCorps.Web, :controller

  alias CodeCorps.SluggedRoute

  def show(conn, %{"slug" => slug}) do
    slugged_route =
      SluggedRoute
      |> CodeCorps.ModelHelpers.slug_finder(slug)

    render(conn, "show.json-api", data: slugged_route)
  end
end

defmodule CodeCorpsWeb.SluggedRouteController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{SluggedRoute, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"slug" => slug}) do
    with %SluggedRoute{} = slugged_route <- SluggedRoute |> Query.slug_finder(slug) do
      conn |> render("show.json-api", data: slugged_route)
    end
  end
end

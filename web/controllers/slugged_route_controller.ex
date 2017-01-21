defmodule CodeCorps.SluggedRouteController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [slug_finder: 2]

  alias CodeCorps.SluggedRoute

  plug JaResource

  def record(%Plug.Conn{params: %{"slug" => slug}}, _id) do
    SluggedRoute |> slug_finder(slug)
  end
end

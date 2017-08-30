defmodule CodeCorpsWeb.SluggedRouteController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [slug_finder: 2]

  alias CodeCorps.SluggedRoute

  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.SluggedRoute

  def record(%Plug.Conn{params: %{"slug" => slug}}, _id) do
    SluggedRoute |> slug_finder(slug)
  end
end

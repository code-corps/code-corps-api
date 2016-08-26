defmodule CodeCorps.SluggedRouteControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.SluggedRoute
  alias CodeCorps.Repo

  @valid_attrs %{organization_id: 42, slug: "some content", user_id: 42}
  @invalid_attrs %{}

  test "shows chosen resource", %{conn: conn} do
    slug = "test-slug"
    slugged_route = Repo.insert! %SluggedRoute{slug: slug}
    conn = get conn, "/#{slug}"
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{slugged_route.id}"
    assert data["type"] == "slugged-route"
    assert data["attributes"]["slug"] == slugged_route.slug
    assert data["attributes"]["organization_id"] == slugged_route.organization_id
    assert data["attributes"]["user_id"] == slugged_route.user_id
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, slugged_route_path(conn, :show, -1)
    end
  end

end

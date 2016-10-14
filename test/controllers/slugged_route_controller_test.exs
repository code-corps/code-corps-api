defmodule CodeCorps.SluggedRouteControllerTest do
  use CodeCorps.ApiCase

  @valid_attrs %{organization_id: 42, slug: "some content", user_id: 42}
  @invalid_attrs %{}

  test "shows chosen resource", %{conn: conn} do
    slug = "test-slug"
    slugged_route = insert(:slugged_route, slug: slug)
    conn = get conn, "/#{slug}"
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{slugged_route.id}"
    assert data["type"] == "slugged-route"
    assert data["attributes"]["slug"] == slugged_route.slug
    assert data["attributes"]["organization_id"] == slugged_route.organization_id
    assert data["attributes"]["user_id"] == slugged_route.user_id
  end

  test "is case insensitive", %{conn: conn} do
    slug = "test"
    insert(:slugged_route, slug: slug)

    assert conn |> get("/test") |> json_response(200)
    assert conn |> get("/tEst") |> json_response(200)
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    path = conn |> slugged_route_path(:show, -1)
    assert conn |> get(path) |> json_response(:not_found)
  end
end

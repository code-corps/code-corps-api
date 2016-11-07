defmodule CodeCorps.SluggedRouteControllerTest do
  use CodeCorps.ApiCase, resource_name: :slugged_route

  @valid_attrs %{organization_id: 42, slug: "some content", user_id: 42}
  @invalid_attrs %{}

  test "shows chosen resource", %{conn: conn} do
    slug = "test-slug"
    slugged_route = insert(:slugged_route, slug: slug)
    conn
    |> get("/#{slug}")
    |> json_response(200)
    |> Map.get("data")
    |> assert_result_id(slugged_route.id)
  end

  test "is case insensitive", %{conn: conn} do
    slug = "test"
    insert(:slugged_route, slug: slug)

    assert conn |> get("/test") |> json_response(200)
    assert conn |> get("/tEst") |> json_response(200)
  end

  test "renders 404 when id is nonexistent", %{conn: conn} do
    assert conn |> request_show(:not_found) |> json_response(404)
  end
end

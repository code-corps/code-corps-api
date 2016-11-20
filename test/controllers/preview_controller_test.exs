defmodule CodeCorps.PreviewControllerTest do
  use CodeCorps.ApiCase, resource_name: :preview

  @valid_attrs %{markdown: "A **strong** element"}

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      attrs = @valid_attrs |> Map.merge(%{user: current_user})
      assert conn |> request_create(attrs) |> json_response(201)
    end

    test "does not create resource, and responds with 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(401)
    end

    @tag :authenticated
    test "does not update resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create(@valid_attrs) |> json_response(403)
    end
  end
end

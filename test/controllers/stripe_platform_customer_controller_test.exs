defmodule CodeCorps.Web.StripePlatformCustomerControllerTest do
  use CodeCorps.ApiCase, resource_name: :stripe_platform_customer

  describe "show" do
    @tag :authenticated
    test "shows chosen resource when user is authenticated and authorized", %{conn: conn, current_user: current_user} do
      stripe_platform_customer = insert(:stripe_platform_customer, user: current_user)

      conn
      |> request_show(stripe_platform_customer)
      |> json_response(200)
      |> assert_id_from_response(stripe_platform_customer.id)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      stripe_platform_customer = insert(:stripe_platform_customer)
      assert conn |> request_show(stripe_platform_customer) |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      stripe_platform_customer = insert(:stripe_platform_customer)
      assert conn |> request_show(stripe_platform_customer) |> json_response(403)
    end

    @tag :authenticated
    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource user is authenticated and authorized", %{conn: conn, current_user: current_user} do
      assert conn |> request_create(%{user: current_user}) |> json_response(201)

      user_id = current_user.id
      assert_received {:track, ^user_id, "Created Stripe Platform Customer", %{}}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end
  end
end

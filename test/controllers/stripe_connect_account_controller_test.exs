defmodule CodeCorps.StripeConnectAccountControllerTest do
  use CodeCorps.ApiCase, resource_name: :stripe_connect_account

  describe "show" do
    @tag :authenticated
    test "shows chosen resource", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, member: current_user, organization: organization, role: "owner")
      stripe_connect_account = insert(:stripe_connect_account, organization: organization)

      conn
      |> request_show(stripe_connect_account)
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(stripe_connect_account.id)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      stripe_connect_account = insert(:stripe_connect_account)
      assert conn |> request_show(stripe_connect_account) |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when unauthorized", %{conn: conn} do
      stripe_connect_account = insert(:stripe_connect_account)
      assert conn |> request_show(stripe_connect_account) |> json_response(403)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource user is authenticated and authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, member: current_user, organization: organization, role: "owner")
      attrs = %{
        access_code: "ac_123",
        organization: organization
      }
      assert conn |> request_create(attrs) |> json_response(201)

      user_id = current_user.id
      assert_received {:track, ^user_id, "Created Stripe Connect Account", %{}}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      organization = insert(:organization)
      attrs = %{
        access_code: "ac_123",
        organization: organization
      }
      assert conn |> request_create(attrs) |> json_response(403)
    end
  end
end

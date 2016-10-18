defmodule CodeCorps.StripeAuthControllerTest do
  use CodeCorps.ApiCase

  describe "stripe_auth" do
    @tag :requires_env
    @tag :authenticated
    test "renders the Stripe Connect button URL when authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, role: "owner", member: current_user, organization: organization)
      project = insert(:project, organization: organization)

      conn = get conn, stripe_auth_path(conn, :stripe_auth, project)
      assert json_response(conn, 200)["data"]["attributes"]["url"]
    end

    @tag :requires_env
    test "renders 401 when not authenticated", %{conn: conn} do
      project = insert(:project)

      conn = get conn, stripe_auth_path(conn, :stripe_auth, project)
      assert json_response(conn, 401)
    end

    @tag :requires_env
    @tag :authenticated
    test "renders a 401 when not authorized", %{conn: conn} do
      project = insert(:project)

      conn = get conn, stripe_auth_path(conn, :stripe_auth, project)
      assert json_response(conn, 401)
    end
  end
end

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
    test "renders a 403 when not authorized", %{conn: conn} do
      project = insert(:project)

      conn = get conn, stripe_auth_path(conn, :stripe_auth, project)
      assert json_response(conn, 403)
    end

    @tag :authenticated
    test "sets redirect_uri from environment", %{conn: conn, current_user: current_user} do
      Application.put_env(:code_corps, :stripe_redirect_uri, "https://example.com")
      organization = insert(:organization)
      insert(:organization_membership, role: "owner", member: current_user, organization: organization)
      project = insert(:project, organization: organization)

      conn = get conn, stripe_auth_path(conn, :stripe_auth, project)
      url = json_response(conn, 200)["data"]["attributes"]["url"]
      query = url |> URI.decode_query
      assert query["redirect_uri"] == "https://example.com"
    end
  end
end

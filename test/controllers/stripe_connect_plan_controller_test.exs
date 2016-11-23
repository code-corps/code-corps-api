defmodule CodeCorps.StripeConnectPlanControllerTest do
  use CodeCorps.ApiCase, resource_name: :stripe_connect_plan



  describe "show" do
    @tag :authenticated
    test "shows resource when authenticated and authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, role: "owner", member: current_user, organization: organization)
      project = insert(:project, organization: organization)

      stripe_connect_plan = insert(:stripe_connect_plan, project: project)
      conn
      |> request_show(stripe_connect_plan)
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(stripe_connect_plan.id)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      stripe_connect_plan = insert(:stripe_connect_plan)

      assert conn |> request_show(stripe_connect_plan) |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      stripe_connect_plan = insert(:stripe_connect_plan)
      assert conn |> request_show(stripe_connect_plan) |> json_response(403)
    end

    @tag :authenticated
    test "renders 404 when record not found", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource user is authenticated and authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, role: "owner", member: current_user, organization: organization)
      insert(:stripe_connect_account, organization: organization)
      project = insert(:project, organization: organization)

      assert conn |> request_create(%{project: project}) |> json_response(201)
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:organization_membership, role: "admin", member: current_user, organization: organization)
      project = insert(:project, organization: organization)

      assert conn |> request_create(%{project: project}) |> json_response(403)
    end
  end
end

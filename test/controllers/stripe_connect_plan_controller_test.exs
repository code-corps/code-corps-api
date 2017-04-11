defmodule CodeCorps.Web.StripeConnectPlanControllerTest do
  use CodeCorps.ApiCase, resource_name: :stripe_connect_plan

  describe "show" do
    @tag :authenticated
    test "shows resource when authenticated and authorized", %{conn: conn, current_user: current_user} do
      project = insert(:project)
      insert(:project_user, project: project, user: current_user, role: "owner")
      stripe_connect_plan = insert(:stripe_connect_plan, project: project)

      conn
      |> request_show(stripe_connect_plan)
      |> json_response(200)
      |> assert_id_from_response(stripe_connect_plan.id)
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
    test "creates and renders resource when user is authenticated and authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:stripe_connect_account, organization: organization, charges_enabled: true, transfers_enabled: true)
      project = insert(:project, organization: organization)
      insert(:project_user, project: project, user: current_user, role: "owner")
      insert(:donation_goal, project: project)

      assert conn |> request_create(%{project: project}) |> json_response(201)

      user_id = current_user.id
      assert_received {:track, ^user_id, "Created Stripe Connect Plan", %{}}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      assert conn |> request_create(%{project: project}) |> json_response(403)
    end

    @tag :authenticated
    test "does not create resource and renders 422 when no donation goals exist and transfers not enabled", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      insert(:stripe_connect_account, organization: organization, transfers_enabled: false)
      project = insert(:project, organization: organization)
      insert(:project_user, project: project, user: current_user, role: "owner")

      assert conn |> request_create(%{project: project}) |> json_response(422)
    end
  end
end

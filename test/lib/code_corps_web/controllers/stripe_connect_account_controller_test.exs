defmodule CodeCorpsWeb.StripeConnectAccountControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :stripe_connect_account

  alias CodeCorps.StripeConnectAccount

  describe "show" do
    @tag :authenticated
    test "shows chosen resource", %{conn: conn, current_user: current_user} do
      organization = insert(:organization, owner: current_user)
      stripe_connect_account = insert(:stripe_connect_account, organization: organization)

      conn
      |> request_show(stripe_connect_account)
      |> json_response(200)
      |> assert_id_from_response(stripe_connect_account.id)
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
    test "creates and renders resource when user is authenticated and authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization, owner: current_user)

      attrs = %{organization: organization, country: "US", tos_acceptance_date: 123456}

      response = conn |> put_req_header("user-agent", "Test agent") |> request_create(attrs)
      assert response |> json_response(201)

      user_id = current_user.id
      assert_received {:track, ^user_id, "Created Stripe Connect Account", %{}}

      account = StripeConnectAccount |> Repo.one

      assert account.tos_acceptance_date
      request_ip = CodeCorps.ConnUtils.extract_ip(response)
      assert account.tos_acceptance_ip == request_ip
      request_user_agent = CodeCorps.ConnUtils.extract_user_agent(response)
      assert account.tos_acceptance_user_agent == request_user_agent
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      organization = insert(:organization)
      attrs = %{ organization: organization }
      assert conn |> request_create(attrs) |> json_response(403)
    end
  end

  describe "update" do
    @tag :authenticated
    test "updates external account on resource when user is authenticated and authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization, owner: current_user)
      stripe_connect_account = insert(:stripe_connect_account, organization: organization)

      attrs = %{external_account: "ba_test123"}

      assert conn |> request_update(stripe_connect_account, attrs) |> json_response(200)

      updated_account = Repo.get(StripeConnectAccount, stripe_connect_account.id)
      assert updated_account.external_account == "ba_test123"
    end

    test "does not update resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_update |> json_response(401)
    end

    @tag :authenticated
    test "does not update resource and renders 403 when not authorized", %{conn: conn} do
      organization = insert(:organization)
      stripe_connect_account = insert(:stripe_connect_account, organization: organization)

      assert conn |> request_update(stripe_connect_account, %{}) |> json_response(403)
    end
  end
end

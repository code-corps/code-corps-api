defmodule CodeCorpsWeb.StripeConnectSubscriptionControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :stripe_connect_subscription

  defp build_payload(user, project, quantity) do
    %{
      "data" => %{
        "attributes" => %{
          "quantity" => quantity,
          "project-id" => project.id
        },
        "relationships" => %{
          "user" => %{"data" => %{"id" => user.id}}
        }
      }
    }
  end

  defp make_create_request(conn, payload) do
    path = conn |> stripe_connect_subscription_path(:create)

    conn |> post(path, payload)
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when user is authenticated and authorized", %{conn: conn, current_user: current_user} do
      # make project ready to accept donations
      organization = insert(:organization)
      insert(:stripe_connect_account, organization: organization, charges_enabled: true)
      project = insert(:project, organization: organization)
      insert(:stripe_connect_plan, project: project)

      # make user ready to donate
      insert(:stripe_platform_customer, user: current_user)
      insert(:stripe_platform_card, user: current_user)

      payload = build_payload(current_user, project, 10)
      assert conn |> make_create_request(payload) |> json_response(201)

      user_id = current_user.id
      assert_received {:track, ^user_id, "Created Stripe Connect Subscription", %{}}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end
  end

  describe "show" do
    @tag :authenticated
    test "shows resource when authenticated and authorized", %{conn: conn, current_user: current_user} do
      stripe_connect_plan = insert(:stripe_connect_plan)
      stripe_connect_subscription =
        insert(:stripe_connect_subscription, user: current_user, stripe_connect_plan: stripe_connect_plan)

      conn
      |> request_show(stripe_connect_subscription)
      |> json_response(200)
      |> assert_id_from_response(stripe_connect_subscription.id)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      stripe_connect_subscription = insert(:stripe_connect_subscription)

      assert conn |> request_show(stripe_connect_subscription) |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      stripe_connect_subscription = insert(:stripe_connect_subscription)
      assert conn |> request_show(stripe_connect_subscription) |> json_response(403)
    end

    @tag :authenticated
    test "renders 404 when record not found", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end
end

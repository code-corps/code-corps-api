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
end

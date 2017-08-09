defmodule CodeCorpsWeb.StripePlatformCardControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :stripe_platform_card

  describe "show" do
    @tag :authenticated
    test "shows resource when authenticated and authorized", %{conn: conn, current_user: current_user} do
      stripe_platform_card = insert(:stripe_platform_card, user: current_user)
      conn
      |> request_show(stripe_platform_card)
      |> json_response(200)
      |> assert_id_from_response(stripe_platform_card.id)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      stripe_platform_card = insert(:stripe_platform_card)

      assert conn |> request_show(stripe_platform_card) |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      stripe_platform_card = insert(:stripe_platform_card)
      assert conn |> request_show(stripe_platform_card) |> json_response(403)
    end

    @tag :authenticated
    test "renders 404 when record not found", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  defp build_payload(%{stripe_token: stripe_token, user: user}) do
    %{
      "data" => %{
        "type" => "stripe-platform-card",
        "attributes" => stripe_token |> to_attributes,
        "relationships" => user |> to_relationships
      },
    }
  end
  defp build_payload(%{}), do: %{"data" => %{"type" => "stripe-platform-card"}}

  defp to_attributes(stripe_token), do: %{"stripe-token" => stripe_token}
  defp to_relationships(user), do: %{"user" => %{"data" => %{"id" => user.id, "type" => "user"}}}

  defp make_create_request(conn, attrs \\ %{}) do
    path = conn |> stripe_platform_card_path(:create)

    payload = build_payload(attrs)
    conn |> post(path, payload)
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      insert(:stripe_platform_customer, user: current_user)
      valid_attrs = %{stripe_token: "tok_test123456", user: current_user}

      assert conn |> make_create_request(valid_attrs) |> json_response(201)

      user_id = current_user.id
      assert_received {:track, ^user_id, "Created Stripe Platform Card", %{}}
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> make_create_request |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> make_create_request |>  json_response(403)
    end
  end
end

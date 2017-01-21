defmodule CodeCorps.StripeService.StripeConnectSubscriptionServiceTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.StripeConnectSubscriptionService

  setup do
    organization = insert(:organization)
    insert(:stripe_connect_account, organization: organization)

    stripe_connect_plan = insert(:stripe_connect_plan)
    project = insert(:project, stripe_connect_plan: stripe_connect_plan, organization: organization)

    user = insert(:user)
    insert(:stripe_platform_customer, user: user)
    insert(:stripe_platform_card, user: user)

    {:ok, project: project, user: user}
  end

  describe "find_or_create/1" do
    test "retrieves and returns a subscription if one is already present", %{project: project, user: user} do
      insert(:stripe_connect_subscription, user: user, stripe_connect_plan: project.stripe_connect_plan, quantity: 300)

      {:ok, subscription} =
        StripeConnectSubscriptionService.find_or_create(%{"project_id" => project.id, "user_id" => user.id, "quantity" => 200})

      assert subscription.quantity == 300
    end

    test "creates and returns a subscription if none is present", %{project: project, user: user} do
      {:ok, subscription} =
        StripeConnectSubscriptionService.find_or_create(%{"project_id" => project.id, "user_id" => user.id, "quantity" => 200})

      assert subscription.quantity == 200
    end
  end
end

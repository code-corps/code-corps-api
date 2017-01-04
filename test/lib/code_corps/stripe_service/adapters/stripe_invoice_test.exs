defmodule CodeCorps.StripeService.Adapters.StripeInvoiceTest do
  use CodeCorps.ModelCase

  import CodeCorps.StripeService.Adapters.StripeInvoiceAdapter, only: [to_params: 1]

  @stripe_invoice %Stripe.Invoice{
    amount_due: 1000,
    application_fee: 50,
    attempt_count: 1,
    attempted: true,
    charge: "ch_123",
    closed: true,
    currency: "usd",
    customer: "cus_123",
    date: 1_483_553_506,
    description: nil,
    discount: nil,
    ending_balance: 0,
    forgiven: false,
    id: "in_123",
    livemode: false,
    metadata: %{},
    next_payment_attempt: nil,
    paid: true,
    period_end: 1_483_553_506,
    period_start: 1_483_553_506,
    receipt_number: nil,
    starting_balance: 0,
    statement_descriptor: nil,
    subscription: "sub_123",
    subscription_proration_date: nil,
    subtotal: 1000,
    tax: nil,
    tax_percent: nil,
    total: 1000,
    webhooks_delivered_at: 1_483_553_511
  }

  @local_map %{
    "amount_due" => 1000,
    "application_fee" => 50,
    "attempt_count" => 1,
    "attempted" => true,
    "charge_id_from_stripe" => "ch_123",
    "closed" => true,
    "currency" => "usd",
    "customer_id_from_stripe" => "cus_123",
    "date" => 1_483_553_506,
    "description" => nil,
    "ending_balance" => 0,
    "forgiven" => false,
    "id_from_stripe" => "in_123",
    "next_payment_attempt" => nil,
    "paid" => true,
    "period_end" => 1_483_553_506,
    "period_start" => 1_483_553_506,
    "receipt_number" => nil,
    "starting_balance" => 0,
    "statement_descriptor" => nil,
    "subscription_id_from_stripe" => "sub_123",
    "subscription_proration_date" => nil,
    "subtotal" => 1000,
    "tax" => nil,
    "tax_percent" => nil,
    "total" => 1000,
    "webhooks_delivered_at" => 1_483_553_511
  }

  describe "to_params/2" do
    test "converts from stripe map to local properly" do
      user = insert(:user)
      stripe_platform_customer = insert(:stripe_platform_customer, user: user)
      insert(:stripe_connect_customer, id_from_stripe: "cus_123", stripe_platform_customer: stripe_platform_customer, user: user).id
      stripe_connect_subscription_id = insert(:stripe_connect_subscription, id_from_stripe: "sub_123", user: user).id

      relationships = %{
        "stripe_connect_subscription_id" => stripe_connect_subscription_id,
        "user_id" => user.id
      }
      local_map = Map.merge(@local_map, relationships)

      {:ok, result} = to_params(@stripe_invoice)
      assert result == local_map
    end
  end
end

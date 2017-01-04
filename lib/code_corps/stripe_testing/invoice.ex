defmodule CodeCorps.StripeTesting.Invoice do
  def retrieve(id, _) do
    {:ok, invoice(id)}
  end

  defp invoice(id) do
    %Stripe.Invoice{
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
      id: id,
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
  end
end

defmodule CodeCorps.StripityStripeTesting.Plan do
  def create(map, _opts) do
    {:ok, do_create(map)}
  end

  defp do_create(_) do
    {:ok, created} = DateTime.from_unix(1479472835)

    %Stripe.Plan{
      id: "plan_9aMOFmqy1esIRE",
      amount: 5000,
      created: created,
      currency: "usd",
      interval: "month",
      interval_count: 1,
      livemode: false,
      metadata: %{},
      name: "Monthly subscription for Code Corps",
      statement_descriptor: nil,
      trial_period_days: nil
    }
  end
end

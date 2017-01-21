defmodule CodeCorps.StripeTesting.Customer do
  def create(map, _opts \\ []) do
    {:ok, do_create(map)}
  end

  def update(id, map, _opts \\ []) do
    {:ok, do_update(id, map)}
  end

  def retrieve(id) do
    {:ok, do_retrieve(id) }
  end

  defp do_create(_) do
    %Stripe.Customer{
      id: "cus_9aMOFmqy1esIRE",
      account_balance: 0,
      created: 1479472835,
      currency: "usd",
      default_source: nil,
      delinquent: false,
      description: nil,
      email: "mail@test.com",
      livemode: false,
      metadata: %{}
    }
  end

  defp do_update(id, map) do
    %Stripe.Customer{
      id: id,
      account_balance: 0,
      created: 1479472835,
      currency: "usd",
      default_source: nil,
      delinquent: false,
      description: nil,
      email: map.email,
      livemode: false,
      metadata: %{}
    }
  end

  defp do_retrieve(id) do
    created = 1479472835

    %Stripe.Customer{
      id: id,
      account_balance: 0,
      created: created,
      currency: "usd",
      default_source: nil,
      delinquent: false,
      description: nil,
      email: "hardcoded@test.com",
      livemode: false,
      metadata: %{}
    }
  end
end

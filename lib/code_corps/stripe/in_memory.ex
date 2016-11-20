defmodule CodeCorps.Stripe.InMemory do
  defmodule Customer do
    def create(map) do
      {:ok, do_create(map)}
    end

    defp do_create(_) do
      {:ok, created} = DateTime.from_unix(1479472835)

      %Stripe.Customer{
        id: "cus_9aMOFmqy1esIRE",
        account_balance: 0,
        created: created,
        currency: "usd",
        default_source: nil,
        delinquent: false,
        description: nil,
        email: "mail@test.com",
        livemode: false,
        metadata: %{}
      }
    end
  end
end

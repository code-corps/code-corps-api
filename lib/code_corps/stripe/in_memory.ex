defmodule CodeCorps.Stripe.InMemory do
  defmodule Card do
    def create(:customer, _stripe_id, _stripe_token) do
      {:ok, do_create}
    end

    defp do_create do
      %Stripe.Card{
        id: "card_19IHPnBKl1F6IRFf8w7gpdOe",
        address_city: nil,
        address_country: nil,
        address_line1: nil,
        address_line1_check: nil,
        address_line2: nil,
        address_state: nil,
        address_zip: nil,
        address_zip_check: nil,
        brand: "Visa",
        country: "US",
        customer: nil,
        cvc_check: "unchecked",
        dynamic_last4: nil,
        exp_month: 11,
        exp_year: 2016,
        funding: "credit",
        last4: "4242",
        metadata: {},
        name: nil,
        tokenization_method: nil
      }
    end
  end

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

defmodule CodeCorps.StripeTesting.ExternalAccount do
  def retrieve(id, _) do
    {:ok, bank_account(id)}
  end

  defp bank_account(id) do
    %Stripe.BankAccount{
      id: id,
      object: "bank_account",
      account: "acct_1032D82eZvKYlo2C",
      account_holder_name: "Jane Austen",
      account_holder_type: "individual",
      bank_name: "STRIPE TEST BANK",
      country: "US",
      currency: "usd",
      default_for_currency: false,
      fingerprint: "1JWtPxqbdX5Gamtc",
      last4: "6789",
      metadata: {},
      routing_number: "110000000",
      status: "new"
    }
  end
end

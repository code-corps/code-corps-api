defmodule CodeCorps.StripeTesting.Account do
  def retrieve(_id) do
    {:ok, do_retrieve}
  end

  defp do_retrieve do
    %Stripe.Account{
      business_name: "Code Corps PBC",
      business_primary_color: nil,
      business_url: "codecorps.org",
      charges_enabled: true,
      country: "US",
      default_currency: "usd",
      details_submitted: true,
      display_name: "Code Corps Customer",
      email: "volunteers@codecorps.org",
      id: "acct_123",
      managed: false,
      metadata: %{},
      statement_descriptor: "CODECORPS.ORG",
      support_email: nil,
      support_phone: "1234567890",
      support_url: nil,
      timezone: "America/Los_Angeles",
      transfers_enabled: true
    }
  end
end

defmodule CodeCorps.StripityStripeTesting.Connect.OAuth do
  def token(_code) do
    {:ok, do_token}
  end

  def do_token do
    %Stripe.Connect.OAuth.TokenResponse{
      access_token: "sk_test_123",
      livemode: false,
      refresh_token: "rt_123",
      scope: "read_write",
      stripe_publishable_key: "pk_test_123",
      stripe_user_id: "acct_123",
      token_type: "bearer"
    }
  end
end

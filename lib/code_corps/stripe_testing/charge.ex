defmodule CodeCorps.StripeTesting.Charge do
  import CodeCorps.StripeTesting.Helpers

  def retrieve(_id, _opts) do
    {:ok, load_fixture(Stripe.Charge, "charge")}
  end
end

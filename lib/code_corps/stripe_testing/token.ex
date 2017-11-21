defmodule CodeCorps.StripeTesting.Token do
  def create(_params, _opts = [connect_account: _]) do
    {:ok, do_create()}
  end

  defp do_create() do
    %Stripe.Token{
      id: "sub_123"
    }
  end
end

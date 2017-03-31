defmodule CodeCorps.StripeService.StripeConnectCardServiceTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  alias CodeCorps.Web.StripeConnectCard
  alias CodeCorps.StripeService.StripeConnectCardService

  describe "update/1" do
    @attributes %{name: "John Doe", exp_month: 6, exp_year: 2030}

    test "it just updates the connect card on Stripe API, not locally" do
      connect_card = insert(:stripe_connect_card)

      connect_card =
        StripeConnectCard
        |> Repo.get(connect_card.id)
        |> Repo.preload([:stripe_platform_card, :stripe_connect_account])

      updated_at = connect_card.updated_at

      {:ok, %Stripe.Card{} = stripe_card} =
        StripeConnectCardService.update(connect_card, @attributes)

      assert stripe_card.id == connect_card.id_from_stripe
      assert stripe_card.name == "John Doe"
      assert stripe_card.exp_year == 2030
      assert stripe_card.exp_month == 6

      connect_card = Repo.get(StripeConnectCard, connect_card.id)

      assert connect_card.updated_at == updated_at
    end
  end
end

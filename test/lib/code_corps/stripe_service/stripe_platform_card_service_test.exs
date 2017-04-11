defmodule CodeCorps.StripeService.StripePlatformCardServiceTest do
  use ExUnit.Case, async: true
  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.StripePlatformCardService
  alias CodeCorps.Web.StripePlatformCard

  describe "update_from_stripe/1" do
    test "it just updates the platform card if there is nothing associated to update" do
      platform_card = insert(:stripe_platform_card)

      {:ok, %StripePlatformCard{} = platform_card, nil} =
        StripePlatformCardService.update_from_stripe(platform_card.id_from_stripe)

      assert platform_card.exp_year == 2020
    end

    # TODO: We can't really do this test until we are able to mock stripe API data
    # test "it returns an {:error, changeset} if there are validation errors with the platform_card" do
    #   platform_card = insert(:stripe_platform_card)

    #   {:error, changeset} =
    #     StripePlatformCardService.update_from_stripe(platform_card.id_from_stripe)

    #   refute changeset.valid?
    # end

    test "it also updates the associated connect cards if there are any" do
      platform_card = insert(:stripe_platform_card)

      [connect_card_1, connect_card_2] = insert_pair(:stripe_connect_card, stripe_platform_card: platform_card)

      {:ok, %StripePlatformCard{} = platform_card, connect_updates} =
        StripePlatformCardService.update_from_stripe(platform_card.id_from_stripe)

      assert platform_card.exp_year == 2020

      platform_card = Repo.get(StripePlatformCard, platform_card.id)
      assert platform_card.exp_year == 2020

      [
        {:ok, %Stripe.Card{} = stripe_record_1},
        {:ok, %Stripe.Card{} = stripe_record_2}
      ] = connect_updates

      assert stripe_record_1.id == connect_card_1.id_from_stripe
      assert stripe_record_1.exp_year == 2020
      assert stripe_record_2.id == connect_card_2.id_from_stripe
      assert stripe_record_2.exp_year == 2020
    end
  end
end

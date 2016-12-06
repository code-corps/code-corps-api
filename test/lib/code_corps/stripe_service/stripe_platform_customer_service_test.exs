defmodule CodeCorps.StripeService.StripePlatformCustomerServiceTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripePlatformCustomer
  alias CodeCorps.StripeService.StripePlatformCustomerService

  describe "update/2" do
    test "performs update" do
      customer = insert(:stripe_platform_customer)
      {
        :ok,
        %StripePlatformCustomer{} = customer,
        %Stripe.Customer{} = stripe_customer
      } = StripePlatformCustomerService.update(customer, %{email: "mail@mail.com"})

      assert customer.email == "mail@mail.com"
      assert stripe_customer.email == "mail@mail.com"
      assert stripe_customer.id == customer.id_from_stripe
    end

    test "returns changeset with validation errors if there is an issue" do
      customer = insert(:stripe_platform_customer)
      {:error, changeset} = StripePlatformCustomerService.update(customer, %{email: nil})
      refute changeset.valid?
    end
  end
end

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

  describe "update_from_stripe" do
    test "performs update using information from Stripe API" do
      customer = insert(:stripe_platform_customer)
      {:ok, %StripePlatformCustomer{} = updated_customer, nil} =
        StripePlatformCustomerService.update_from_stripe(customer.id_from_stripe)

      # Hardcoded in StripeTesting.Customer
      assert updated_customer.email == "hardcoded@test.com"
      customer = Repo.get(StripePlatformCustomer, customer.id)
      assert customer.email == "hardcoded@test.com"
    end

    test "also performs update of connect customers if any" do
      platform_customer = insert(:stripe_platform_customer)

      [connect_customer_1, connect_customer_2] =
        insert_pair(:stripe_connect_customer, stripe_platform_customer: platform_customer)

      {:ok, %StripePlatformCustomer{} = updated_customer, connect_updates} =
        StripePlatformCustomerService.update_from_stripe(platform_customer.id_from_stripe)

      # Hardcoded in StripeTesting.Customer
      assert updated_customer.email == "hardcoded@test.com"
      platform_customer = Repo.get(StripePlatformCustomer, platform_customer.id)
      assert platform_customer.email == "hardcoded@test.com"

      [
        {:ok, %Stripe.Customer{} = stripe_record_1},
        {:ok, %Stripe.Customer{} = stripe_record_2}
      ] = connect_updates

      assert stripe_record_1.id == connect_customer_1.id_from_stripe
      assert stripe_record_1.email == "hardcoded@test.com"
      assert stripe_record_2.id == connect_customer_2.id_from_stripe
      assert stripe_record_2.email == "hardcoded@test.com"
    end
  end
end

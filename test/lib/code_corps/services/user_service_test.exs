defmodule CodeCorps.Services.UserServiceTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  alias CodeCorps.StripePlatformCustomer
  alias CodeCorps.Services.UserService

  describe "update/1" do
    test "it just updates the user if there is nothing associated to update" do
      user = insert(:user, email: "mail@mail.com", first_name: "Joe")

      {:ok, user, nil, nil}
        = UserService.update(user, %{email: "changed@mail.com"})

      assert user.email == "changed@mail.com"
      assert user.first_name == "Joe"
    end

    test "it returns an {:error, changeset} if there are validation errors with the user" do
      user = insert(:user, email: "mail@mail.com")
      {:error, changeset} = UserService.update(user, %{email: ""})

      refute changeset.valid?
    end

    test "it just updates the user if the changeset does not contain an email" do
      user = insert(:user, email: "mail@mail.com")
      stripe_platform_customer = insert(:stripe_platform_customer, email: "mail@mail.com", user: user)

      {:ok, user, nil, nil}
        = UserService.update(user, %{first_name: "Mark"})

      assert user.first_name == "Mark"
      assert user.email == "mail@mail.com"

      stripe_platform_customer = Repo.get(StripePlatformCustomer, stripe_platform_customer.id)

      assert stripe_platform_customer.email == "mail@mail.com"
    end

    test "it also updates the associated platform customer if there is one" do
      user = insert(:user, email: "mail@mail.com")
      platform_customer = insert(:stripe_platform_customer, user: user)

      {:ok, user, %StripePlatformCustomer{}, nil}
        = UserService.update(user, %{email: "changed@mail.com"})

      assert user.email == "changed@mail.com"

      platform_customer = Repo.get(StripePlatformCustomer, platform_customer.id)

      assert platform_customer.email == "changed@mail.com"
    end

    test "it also updates the associated connect customers if there are any" do
      user = insert(:user, email: "mail@mail.com")

      platform_customer = %{id_from_stripe: platform_customer_id}
        = insert(:stripe_platform_customer, user: user)

      [connect_customer_1, connect_customer_2] =
        insert_pair(:stripe_connect_customer, stripe_platform_customer: platform_customer)

      {:ok, user, %StripePlatformCustomer{}, connect_updates} = UserService.update(user, %{email: "changed@mail.com"})
      assert user.email == "changed@mail.com"

      platform_customer = Repo.get_by(StripePlatformCustomer, id_from_stripe: platform_customer_id)
      assert platform_customer.email == "changed@mail.com"

      [
        {:ok, %Stripe.Customer{} = stripe_record_1},
        {:ok, %Stripe.Customer{} = stripe_record_2}
      ] = connect_updates

      original_ids_from_stripe =
        [connect_customer_1, connect_customer_2]
        |> Enum.map(&Map.get(&1, :id_from_stripe))
        |> Enum.sort

      result_ids_from_stripe =
        [stripe_record_1, stripe_record_2]
        |> Enum.map(&Map.get(&1, :id))
        |> Enum.sort

      assert result_ids_from_stripe == original_ids_from_stripe
      assert stripe_record_1.email == "changed@mail.com"
      assert stripe_record_2.email == "changed@mail.com"
    end
  end
end

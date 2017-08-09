defmodule CodeCorps.StripeConnectChargeTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeConnectCharge

  test "requires :id_from_stripe, :stripe_connect_customer_id, :user_id" do
    changeset = %StripeConnectCharge{} |> StripeConnectCharge.create_changeset(%{})

    refute changeset.valid?

    assert_validation_triggered(changeset, :id_from_stripe, :required)
    assert_validation_triggered(changeset, :stripe_connect_customer_id, :required)
    assert_validation_triggered(changeset, :user_id, :required)
  end

  test "ensures stripe_connect_account exists" do
    attrs = %{
      id_from_stripe: "test",
      stripe_connect_account_id: -1,
      stripe_connect_customer_id: -1,
      user_id: -1
    }

    changeset = %StripeConnectCharge{} |> StripeConnectCharge.create_changeset(attrs)

    {:error, changeset} = changeset |> Repo.insert

    assert_error_message(changeset, :stripe_connect_account, "does not exist")
  end

  test "ensures stripe_connect_customer exists" do
    account = insert(:stripe_connect_account)
    attrs = %{
      id_from_stripe: "test",
      stripe_connect_account_id: account.id,
      stripe_connect_customer_id: -1,
      user_id: -1
    }

    changeset = %StripeConnectCharge{} |> StripeConnectCharge.create_changeset(attrs)

    {:error, changeset} = changeset |> Repo.insert

    assert_error_message(changeset, :stripe_connect_customer, "does not exist")
  end

  test "ensures user exists" do
    account = insert(:stripe_connect_account)
    customer = insert(:stripe_connect_customer)
    attrs = %{
      id_from_stripe: "test",
      stripe_connect_account_id: account.id,
      stripe_connect_customer_id: customer.id,
      user_id: -1
    }

    changeset = %StripeConnectCharge{} |> StripeConnectCharge.create_changeset(attrs)

    {:error, changeset} = changeset |> Repo.insert

    assert_error_message(changeset, :user, "does not exist")
  end

  test "ensures uniqueness of :id_from_stripe" do
    insert(:stripe_connect_charge, id_from_stripe: "exists")

    account = insert(:stripe_connect_account)
    customer = insert(:stripe_connect_customer)
    user = insert(:user)

    attrs = %{
      id_from_stripe: "exists",
      stripe_connect_account_id: account.id,
      stripe_connect_customer_id: customer.id,
      user_id: user.id
    }

    changeset = %StripeConnectCharge{} |> StripeConnectCharge.create_changeset(attrs)

    {:error, changeset} = changeset |> Repo.insert

    assert_error_message(changeset, :id_from_stripe, "has already been taken")
  end
end

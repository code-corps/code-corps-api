defmodule CodeCorps.StripeInvoiceTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeInvoice

  @valid_attrs %{
    charge_id_from_stripe: "ch_123",
    customer_id_from_stripe: "cus_123",
    id_from_stripe: "in_123",
    subscription_id_from_stripe: "sub_123"
  }

  test "changeset with valid attributes" do
    user_id = insert(:user).id
    stripe_connect_subscription_id = insert(:stripe_connect_subscription).id
    relationships = %{user_id: user_id, stripe_connect_subscription_id: stripe_connect_subscription_id}

    attrs = Map.merge(@valid_attrs, relationships)

    changeset =
      %StripeInvoice{}
      |> StripeInvoice.create_changeset(attrs)

    assert changeset.valid?
  end

  test "changeset requires user_id" do
    stripe_connect_subscription_id = insert(:stripe_connect_subscription).id
    relationships = %{stripe_connect_subscription_id: stripe_connect_subscription_id}

    attrs = Map.merge(@valid_attrs, relationships)

    changeset =
      %StripeInvoice{}
      |> StripeInvoice.create_changeset(attrs)

    refute changeset.valid?
    assert_error_message(changeset, :user_id, "can't be blank")
  end

  test "changeset requires stripe_connect_subscription_id" do
    user_id = insert(:user).id
    relationships = %{user_id: user_id}

    attrs = Map.merge(@valid_attrs, relationships)

    changeset =
      %StripeInvoice{}
      |> StripeInvoice.create_changeset(attrs)

    refute changeset.valid?
    assert_error_message(changeset, :stripe_connect_subscription_id, "can't be blank")
  end

  test "changeset requires id of actual user" do
    user_id = -1
    stripe_connect_subscription_id = insert(:stripe_connect_subscription).id
    relationships = %{user_id: user_id, stripe_connect_subscription_id: stripe_connect_subscription_id}

    attrs = Map.merge(@valid_attrs, relationships)

    {result, changeset} =
      %StripeInvoice{}
      |> StripeInvoice.create_changeset(attrs)
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert_error_message(changeset, :user, "does not exist")
  end

  test "changeset requires id of actual stripe_connect_subscription" do
    user_id = insert(:user).id
    stripe_connect_subscription_id = -1
    relationships = %{user_id: user_id, stripe_connect_subscription_id: stripe_connect_subscription_id}

    attrs = Map.merge(@valid_attrs, relationships)

    {result, changeset} =
      %StripeInvoice{}
      |> StripeInvoice.create_changeset(attrs)
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert_error_message(changeset, :stripe_connect_subscription, "does not exist")
  end
end

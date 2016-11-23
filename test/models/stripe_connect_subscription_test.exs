defmodule CodeCorps.StripeConnectSubscriptionTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeConnectSubscription

  @valid_attrs %{
    id_from_stripe: "abc123",
    plan_id_from_stripe: "abc123"
  }

  @invalid_attrs %{}

  describe "create_changeset/2" do
    test "reports as valid when attributes are valid" do
      stripe_connect_plan_id = insert(:stripe_connect_plan).id
      user_id = insert(:user).id

      changes = Map.merge(@valid_attrs, %{stripe_connect_plan_id: stripe_connect_plan_id, user_id: user_id})
      changeset = StripeConnectSubscription.create_changeset(%StripeConnectSubscription{}, changes)
      assert changeset.valid?
    end

    test "reports as invalid when attributes are invalid" do
      changeset = StripeConnectSubscription.create_changeset(%StripeConnectSubscription{}, @invalid_attrs)
      refute changeset.valid?

      assert changeset.errors[:id_from_stripe] == {"can't be blank", []}
      assert changeset.errors[:plan_id_from_stripe] == {"can't be blank", []}
      assert changeset.errors[:stripe_connect_plan_id] == {"can't be blank", []}
    end

    test "ensures stripe_connect_plan_id links to existing_record" do
      user_id = insert(:user).id
      attrs =  @valid_attrs |> Map.merge(%{stripe_connect_plan_id: -1, user_id: user_id})

      { result, changeset } =
        StripeConnectSubscription.create_changeset(%StripeConnectSubscription{}, attrs)
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert changeset.errors[:stripe_connect_plan] == {"does not exist", []}
    end

    test "ensures user_id links to existing_record" do
      stripe_connect_plan_id = insert(:stripe_connect_plan).id
      attrs =  @valid_attrs |> Map.merge(%{stripe_connect_plan_id: stripe_connect_plan_id, user_id: -1})

      { result, changeset } =
        StripeConnectSubscription.create_changeset(%StripeConnectSubscription{}, attrs)
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert changeset.errors[:user] == {"does not exist", []}
    end
  end
end

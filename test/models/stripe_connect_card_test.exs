defmodule CodeCorps.StripeConnectCardTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeConnectCard

  @valid_attrs %{
    id_from_stripe: "abc123"
  }

  @invalid_attrs %{}

  describe "create_changeset/2" do
    test "reports as valid when attributes are valid" do
      ids = %{
         stripe_connect_account_id: insert(:stripe_connect_account).id,
         stripe_platform_card_id: insert(:stripe_platform_card).id
       }

      changes =
        @valid_attrs
        |> Map.merge(ids)

      changeset =
        %StripeConnectCard{}
        |> StripeConnectCard.create_changeset(changes)

      assert changeset.valid?
    end

    test "reports as invalid when attributes are invalid" do
      changeset = StripeConnectCard.create_changeset(%StripeConnectCard{}, @invalid_attrs)

      refute changeset.valid?

      assert_error_message(changeset, :id_from_stripe, "can't be blank")
      assert_error_message(changeset, :stripe_connect_account_id, "can't be blank")
      assert_error_message(changeset, :stripe_platform_card_id, "can't be blank")
    end

    test "ensures associations to existing stripe_connect_account" do
      ids = %{
         stripe_connect_account_id: -1,
         stripe_platform_card_id: insert(:stripe_platform_card).id
       }

      attrs =
        @valid_attrs
        |> Map.merge(ids)

      {result, changeset} =
        %StripeConnectCard{}
        |> StripeConnectCard.create_changeset(attrs)
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert_error_message(changeset, :stripe_connect_account, "does not exist")
    end

    test "ensures associations to existing stripe_platform_card" do
      ids = %{
         stripe_connect_account_id: insert(:stripe_connect_account).id,
         stripe_platform_card_id: -1
       }

      attrs =
        @valid_attrs
        |> Map.merge(ids)

      {result, changeset} =
        %StripeConnectCard{}
        |> StripeConnectCard.create_changeset(attrs)
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert_error_message(changeset, :stripe_platform_card, "does not exist")
    end
  end
end

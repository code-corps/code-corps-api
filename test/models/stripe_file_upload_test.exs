defmodule CodeCorps.StripeFileUploadTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeFileUpload

  @valid_attrs %{
    id_from_stripe: "abc123"
  }

  @invalid_attrs %{}

  describe "create_changeset/2" do
    test "reports as valid when attributes are valid" do
      changeset = StripeFileUpload.create_changeset(%StripeFileUpload{}, @valid_attrs)

      assert changeset.valid?
    end

    test "reports as invalid when attributes are invalid" do
      changeset = StripeFileUpload.create_changeset(%StripeFileUpload{}, @invalid_attrs)
      refute changeset.valid?

      assert changeset.errors[:id_from_stripe] == {"can't be blank", []}
    end

    test "can optionally belong to a StripeConnectAccount" do
      stripe_connect_account_id = insert(:stripe_connect_account).id
      changes = Map.merge(@valid_attrs, %{stripe_connect_account_id: stripe_connect_account_id})
      changeset = StripeFileUpload.create_changeset(%StripeFileUpload{}, changes)

      assert changeset.valid?
    end

    test "existing StripeConnectAccount association is required" do
      stripe_connect_account_id = "abc456"
      changes = Map.merge(@valid_attrs, %{stripe_connect_account_id: stripe_connect_account_id})
      changeset = StripeFileUpload.create_changeset(%StripeFileUpload{}, changes)

      refute changeset.valid?
      assert changeset.errors[:stripe_connect_account_id] == {"is invalid", [type: :id]}
    end
  end
end

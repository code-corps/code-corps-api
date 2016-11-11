defmodule CodeCorps.StripeConnectAccountTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeConnectAccount

  @valid_attrs %{
    id_from_stripe: "abc123"
  }

  @invalid_attrs %{}

  describe "create_changeset/2" do
    test "reports as valid when attributes are valid" do
      organization_id = insert(:organization).id

      changes = Map.merge(@valid_attrs, %{organization_id: organization_id})
      changeset = StripeConnectAccount.create_changeset(%StripeConnectAccount{}, changes)
      assert changeset.valid?
    end

    test "reports as invalid when attributes are invalid" do
      changeset = StripeConnectAccount.create_changeset(%StripeConnectAccount{}, @invalid_attrs)
      refute changeset.valid?

      assert changeset.errors[:id_from_stripe] == {"can't be blank", []}
      assert changeset.errors[:organization_id] == {"can't be blank", []}
    end

    test "ensures associations link to records that exist" do
      attrs =  @valid_attrs |> Map.merge(%{organization_id: -1})

      { result, changeset } =
        StripeConnectAccount.create_changeset(%StripeConnectAccount{}, attrs)
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert changeset.errors[:organization] == {"does not exist", []}
    end
  end
end

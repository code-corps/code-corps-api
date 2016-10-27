defmodule CodeCorps.StripeCardTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeCard

  @valid_attrs %{
    id_from_stripe: "abc123"
  }

  @invalid_attrs %{}

  describe "create_changeset/2" do
    test "reports as valid when attributes are valid" do
      user_id = insert(:user).id

      changes = Map.merge(@valid_attrs, %{user_id: user_id})
      changeset = StripeCard.create_changeset(%StripeCard{}, changes)
      assert changeset.valid?
    end

    test "reports as invalid when attributes are invalid" do
      changeset = StripeCard.create_changeset(%StripeCard{}, @invalid_attrs)
      refute changeset.valid?

      assert changeset.errors[:id_from_stripe] == {"can't be blank", []}
      assert changeset.errors[:user_id] == {"can't be blank", []}
    end

    test "ensures associations link to records that exist" do
      attrs =  @valid_attrs |> Map.merge(%{user_id: -1})

      { result, changeset } =
        StripeCard.create_changeset(%StripeCard{}, attrs)
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert changeset.errors[:user] == {"does not exist", []}
    end
  end
end

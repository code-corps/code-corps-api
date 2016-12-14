defmodule CodeCorps.StripeExternalAccountTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeExternalAccount

  @valid_attrs %{account_id_from_stripe: "some content", id_from_stripe: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = StripeExternalAccount.changeset(%StripeExternalAccount{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = StripeExternalAccount.changeset(%StripeExternalAccount{}, @invalid_attrs)
    refute changeset.valid?
  end
end

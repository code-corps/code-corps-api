defmodule CodeCorps.Web.StripePlatformCustomerTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Web.StripePlatformCustomer

  @valid_attrs %{
    id_from_stripe: "abc123"
  }

  @invalid_attrs %{}

  describe "create_changeset/2" do
    test "reports as valid when attributes are valid" do
      user_id = insert(:user).id

      changes = Map.merge(@valid_attrs, %{user_id: user_id})
      changeset = StripePlatformCustomer.create_changeset(%StripePlatformCustomer{}, changes)
      assert changeset.valid?
    end

    test "reports as invalid when attributes are invalid" do
      changeset = StripePlatformCustomer.create_changeset(%StripePlatformCustomer{}, @invalid_attrs)
      refute changeset.valid?

      changeset |> assert_validation_triggered(:id_from_stripe, :required)
      changeset |> assert_validation_triggered(:user_id, :required)
    end

    test "ensures associations link to records that exist" do
      attrs =  @valid_attrs |> Map.merge(%{user_id: -1})

      {result, changeset} =
        %StripePlatformCustomer{}
        |> StripePlatformCustomer.create_changeset(attrs)
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      changeset |> assert_error_message(:user, "does not exist")
    end
  end

  describe "update_changeset/2" do
    test "reports as valid when attributes are valid" do
      platform_customer = insert(:stripe_platform_customer)

      changeset = StripePlatformCustomer.update_changeset(platform_customer, %{email: "changed@mail.com"})
      assert changeset.valid?
    end

    test "requires email" do
      platform_customer = insert(:stripe_platform_customer)

      changeset = StripePlatformCustomer.update_changeset(platform_customer, %{email: nil})
      refute changeset.valid?

      changeset |> assert_validation_triggered(:email, :required)
    end
  end
end

defmodule CodeCorps.StripeService.StripeConnectAccountServiceTest do
  use CodeCorps.StripeCase

  alias CodeCorps.{StripeConnectAccount, StripeExternalAccount}
  alias CodeCorps.StripeService.StripeConnectAccountService

  describe "create" do
    test "creates a StripeConnectAccount" do
      organization = insert(:organization)

      attributes = %{
        "country" => "US",
        "organization_id" => organization.id,
        "tos_acceptance_date" => 123456
      }

      {:ok, %StripeConnectAccount{} = connect_account} =
        StripeConnectAccountService.create(attributes)

      assert connect_account.country == "US"
      assert connect_account.organization_id == organization.id
      assert connect_account.type == "custom"
      assert connect_account.tos_acceptance_date == 123456
    end
  end

  describe "update/2" do
    test "assigns the external_account property to the record, creates external account" do
      connect_account = insert(:stripe_connect_account)

      {:ok, %StripeConnectAccount{} = updated_account} =
        StripeConnectAccountService.update(connect_account, %{"external_account" =>"ba_123"})
      assert updated_account.external_account == "ba_123"

      assert Repo.get_by(StripeExternalAccount, stripe_connect_account_id: connect_account.id)
    end
  end

  describe "update_from_stripe/1" do
    test "updates connect account with stripe information, creates external_account" do
      # we use a preset fixture from StripeTesting
      # the fixture is for multiple external accounts, because we want to make sure
      # that part is not failing due to us only supporting a has_one relationship
      id_from_stripe = "account_with_multiple_external_accounts"

      connect_account = insert(:stripe_connect_account, id_from_stripe: id_from_stripe)

      {:ok, %StripeConnectAccount{} = updated_account} =
        StripeConnectAccountService.update_from_stripe(id_from_stripe)

      assert updated_account.business_name == "Some Company Inc."

      assert Repo.get_by(StripeExternalAccount, stripe_connect_account_id: connect_account.id)
    end

    test "deletes old external account, if it exists" do
      # we use a preset fixture from StripeTesting
      # the fixture is for multiple external accounts, because we want to make sure
      # that part is not failing due to us only supporting a has_one relationship
      id_from_stripe = "account_with_multiple_external_accounts"

      connect_account = insert(:stripe_connect_account, id_from_stripe: id_from_stripe)
      external_account = insert(:stripe_external_account, stripe_connect_account: connect_account)

      {:ok, %StripeConnectAccount{} = updated_account} =
        StripeConnectAccountService.update_from_stripe(id_from_stripe)

      assert updated_account.business_name == "Some Company Inc."

      assert Repo.get(StripeExternalAccount, external_account.id) == nil
      assert Repo.get_by(StripeExternalAccount, stripe_connect_account_id: connect_account.id)
    end
  end
end

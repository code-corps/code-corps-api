defmodule CodeCorps.StripeService.StripeConnectAccountServiceTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  alias CodeCorps.{StripeConnectAccount}
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
      assert connect_account.managed == true
      assert connect_account.tos_acceptance_date == 123456
    end
  end

  describe "update/2" do
    test "assigns the external_account property to the record" do
      account = insert(:stripe_connect_account)

      {:ok, %StripeConnectAccount{} = updated_account} =
        StripeConnectAccountService.update(account, %{"external_account" =>"ba_123"})
      assert updated_account.external_account == "ba_123"
    end
  end
end

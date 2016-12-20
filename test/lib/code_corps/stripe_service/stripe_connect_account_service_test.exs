defmodule CodeCorps.StripeService.StripeConnectAccountServiceTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.StripeConnectAccountService

  describe "create" do
    test "creates a StripeConnectAccount" do
      organization = insert(:organization)

      attributes = %{"country" => "US", "organization_id" => organization.id}

      {:ok, %CodeCorps.StripeConnectAccount{} = connect_account} =
              StripeConnectAccountService.create(attributes)

      assert connect_account.country == "US"
      assert connect_account.organization_id == organization.id
      assert connect_account.managed == true
    end
  end
end

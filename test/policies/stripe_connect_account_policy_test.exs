defmodule CodeCorps.Web.StripeConnectAccountPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Web.StripeConnectAccountPolicy,
    only: [show?: 2, create?: 2, update?: 2]

  import CodeCorps.Web.StripeConnectAccount, only: [create_changeset: 2]

  alias CodeCorps.Web.StripeConnectAccount

  describe "show?" do
    test "returns true when user is owner of organization" do
      user = insert(:user)
      organization = insert(:organization, owner: user)

      stripe_connect_account = insert(:stripe_connect_account, organization: organization)

      assert show?(user, stripe_connect_account)
    end

    test "returns false otherwise" do
      user = insert(:user)
      organization = insert(:organization)

      stripe_connect_account = insert(:stripe_connect_account, organization: organization)

      refute show?(user, stripe_connect_account)
    end
  end

  describe "create?" do
    test "returns true when user is owner of organization" do
      user = insert(:user)
      organization = insert(:organization, owner: user)

      changeset = create_changeset(%StripeConnectAccount{}, %{organization_id: organization.id})

      assert create?(user, changeset)
    end

    test "returns false otherwise" do
      user = insert(:user)
      organization = insert(:organization)

      changeset = create_changeset(%StripeConnectAccount{}, %{organization_id: organization.id})

      refute create?(user, changeset)
    end
  end

  describe "update?" do
    test "returns true when user is owner of organization" do
      user = insert(:user)
      organization = insert(:organization, owner: user)

      stripe_connect_account = insert(:stripe_connect_account, organization: organization)

      assert show?(user, stripe_connect_account)
    end

    test "returns false otherwise" do
      user = insert(:user)
      organization = insert(:organization)

      stripe_connect_account = insert(:stripe_connect_account, organization: organization)

      refute update?(user, stripe_connect_account)
    end
  end
end

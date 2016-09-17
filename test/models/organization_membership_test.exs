defmodule CodeCorps.OrganizationMembershipTest do
  use CodeCorps.ModelCase

  alias CodeCorps.OrganizationMembership

  describe "update_changeset role validation" do
    test "includes pending" do
      attrs = %{role: "pending"}
      changeset = OrganizationMembership.update_changeset(%OrganizationMembership{}, attrs)
      assert changeset.valid?
    end

    test "includes contributor" do
      attrs = %{role: "contributor"}
      changeset = OrganizationMembership.update_changeset(%OrganizationMembership{}, attrs)
      assert changeset.valid?
    end

    test "includes admin" do
      attrs = %{role: "admin"}
      changeset = OrganizationMembership.update_changeset(%OrganizationMembership{}, attrs)
      assert changeset.valid?
    end

    test "includes owner" do
      attrs = %{role: "owner"}
      changeset = OrganizationMembership.update_changeset(%OrganizationMembership{}, attrs)
      assert changeset.valid?
    end

    test "does not include invalid values" do
      attrs = %{role: "invalid"}
      changeset = OrganizationMembership.update_changeset(%OrganizationMembership{}, attrs)
      refute changeset.valid?
    end
  end

  describe "create_changeset" do
    @valid_attrs %{member_id: 1, organization_id: 2}
    @invalid_attrs %{}

    test "changeset with valid attributes" do
      changeset = OrganizationMembership.create_changeset(%OrganizationMembership{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = OrganizationMembership.create_changeset(%OrganizationMembership{}, @invalid_attrs)
      refute changeset.valid?

      assert changeset.errors[:member_id] == {"can't be blank", []}
      assert changeset.errors[:organization_id] == {"can't be blank", []}
    end

    test "changeset ensures member and organization actually exist" do
      changeset = OrganizationMembership.create_changeset(%OrganizationMembership{}, @valid_attrs)

      { result, changeset } = changeset |> Repo.insert

      assert result == :error
      assert changeset.errors[:organization] == {"does not exist", []}

      # assoc_constraint works through one relationship at a time
      organization = insert(:organization)
      attrs = Map.merge(@valid_attrs, %{organization_id: organization.id})
      changeset = OrganizationMembership.create_changeset(%OrganizationMembership{}, attrs)

      { result, changeset } = changeset |> Repo.insert

      assert result == :error
      assert changeset.errors[:member] == {"does not exist", []}
    end
  end
end

defmodule CodeCorps.OrganizationInviteTest do
  use CodeCorps.ModelCase

  alias CodeCorps.OrganizationInvite

  @valid_attrs %{email: "code@corps.com", title: "Code Corps"}
  @invalid_attrs %{}

  describe "changeset" do
    test "with valid attributes" do
      changeset = OrganizationInvite.changeset(%OrganizationInvite{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = OrganizationInvite.changeset(%OrganizationInvite{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "field fulfilled changes only from false to true" do
      changeset = OrganizationInvite.changeset(%OrganizationInvite{fulfilled: false}, Map.put(@valid_attrs, :fulfilled, true))
      assert changeset.valid?

      changeset = OrganizationInvite.changeset(%OrganizationInvite{fulfilled: true}, Map.put(@valid_attrs, :fulfilled, false))
      refute changeset.valid?
    end
  end


 describe "creation_changeset" do
   test "with valid attributes" do
     changeset = OrganizationInvite.create_changeset(%OrganizationInvite{}, @valid_attrs)
     assert changeset.valid?
   end

   test "with invalid attributes" do
     changeset = OrganizationInvite.create_changeset(%OrganizationInvite{}, @invalid_attrs)
     refute changeset.valid?
   end

   test "genearates code" do
     changeset = OrganizationInvite.create_changeset(%OrganizationInvite{}, @valid_attrs)
     assert changeset.changes.code != nil
   end
 end
end

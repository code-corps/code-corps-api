defmodule CodeCorps.OrganizationsTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.{Organization, Organizations, OrganizationInvite}
  alias Ecto.Changeset

  describe "create/1" do
    test "creates an organization" do
      %{id: owner_id} = insert(:user)
      attrs = %{
        "cloudinary_public_id" => "Baz",
        "description" => "Bar",
        "name" => "Foo",
        "owner_id" => owner_id
      }
      {:ok, %Organization{} = organization} = Organizations.create(attrs)

      assert organization.name == "Foo"
      assert organization.description == "Bar"
      assert organization.cloudinary_public_id == "Baz"
    end

    test "returns changeset tuple if there are validation errors"do
      {:error, %Changeset{} = changeset} = Organizations.create(%{})
      refute changeset.valid?
    end

    test "fulfills associated organization invite if invite code provided" do
      %{code: invite_code, id: invite_id} = insert(:organization_invite)
      %{id: owner_id} = insert(:user)
      attrs = %{
        "cloudinary_public_id" => "Baz",
        "description" => "Bar",
        "invite_code" => invite_code,
        "name" => "Foo",
        "owner_id" => owner_id
      }
      {:ok, %Organization{id: organization_id}} = Organizations.create(attrs)

      associated_organization_id =
        OrganizationInvite |> Repo.get(invite_id) |> Map.get(:organization_id)
      assert associated_organization_id == organization_id
    end
  end
end

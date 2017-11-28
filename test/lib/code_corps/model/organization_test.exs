defmodule CodeCorps.OrganizationTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Organization


  describe "changeset" do
    @valid_attrs %{description: "Building a better future.", name: "Code Corps"}
    @invalid_attrs %{}
    test "with valid attributes" do
      changeset = Organization.changeset(%Organization{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Organization.changeset(%Organization{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "create_changeset" do
    @valid_attrs %{
      cloudinary_public_id: "foo",
      description: "Building a better future.",
      name: "Code Corps",
      owner_id: 1
    }
    @invalid_attrs %{}

    test "with valid attributes" do
      changeset = Organization.create_changeset(%Organization{}, @valid_attrs)
      assert changeset.valid?
      assert changeset.changes.slug == "code-corps"
    end

    test "with invalid attributes" do
      changeset = Organization.create_changeset(%Organization{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "ensures owner (user) exists" do
      changeset = Organization.create_changeset(%Organization{}, @valid_attrs)

      {result, changeset} = changeset |> Repo.insert

      assert result == :error
      changeset |> assert_error_message(:owner, "does not exist")
    end

    test "sets approved to false" do
      changeset = Organization.create_changeset(%Organization{}, @valid_attrs)
      assert changeset |> get_field(:approved) == false
    end

    test "generates slug if none provided" do
      changeset = Organization.create_changeset(%Organization{}, @valid_attrs)
      assert changeset |> get_field(:slug) == "code-corps"
    end

    test "leaves out slug generation if slug is provided" do
      attrs = @valid_attrs |> Map.put(:slug, "custom-slug")
      changeset = Organization.create_changeset(%Organization{}, attrs)
      assert changeset |> get_field(:slug) == "custom-slug"
    end
  end
end

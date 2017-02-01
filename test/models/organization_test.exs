defmodule CodeCorps.OrganizationTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Organization

  @valid_attrs %{description: "Building a better future.", name: "Code Corps"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Organization.changeset(%Organization{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "create changeset with valid attributes" do
    changeset = Organization.create_changeset(%Organization{}, @valid_attrs)
    assert changeset.valid?
    assert changeset.changes.slug == "code-corps"
  end

  test "create changeset with invalid attributes" do
    changeset = Organization.create_changeset(%Organization{}, @invalid_attrs)
    refute changeset.valid?
  end
end

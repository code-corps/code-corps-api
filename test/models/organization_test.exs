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

  @tag :requires_env
  test "uploads base64icon data to aws" do
    # 1x1 black pixel gif
    icon_data = "data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs="
    organization = insert_organization
    attrs = %{base64_icon_data: icon_data, title: "Test"}

    changeset = Organization.changeset(organization, attrs)

    assert changeset.valid?
    [_, file_type] = changeset.changes.icon.file_name |> String.split(".")
    assert file_type == "gif"
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

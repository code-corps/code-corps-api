defmodule CodeCorps.Web.RoleTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Web.Role

  @valid_attrs %{ability: "Backend Development", kind: "technology", name: "Backend Developer"}
  @invalid_attrs %{ability: "Juggling", kind: "circus", name: "Juggler"}
  @empty_attrs %{}

  test "changeset with valid attributes" do
    changeset = Role.changeset(%Role{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Role.changeset(%Role{}, @invalid_attrs)
    assert_error_message(changeset, :kind, "is invalid")
    refute changeset.valid?
  end

  test "changeset with empty attributes" do
    changeset = Role.changeset(%Role{}, @empty_attrs)
    refute changeset.valid?
  end
end

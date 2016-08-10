defmodule CodeCorps.CategoryTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Category

  @valid_attrs %{description: "You want to improve software tools and infrastructure.", name: "Technology", slug: "technology"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Category.changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "create changeset with valid attributes" do
    changeset = Category.create_changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
    assert changeset.changes.slug == "technology"
  end

  test "create changeset with invalid attributes" do
    changeset = Category.create_changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end
end

defmodule CodeCorps.CategoryTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Category

  @valid_attrs %{description: "The technology category", name: "Technology", slug: "technology"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Category.changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end
end

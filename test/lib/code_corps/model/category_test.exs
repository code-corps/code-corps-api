defmodule CodeCorps.CategoryTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Category

  @valid_attrs %{description: "You want to improve software tools and infrastructure.", name: "Technology", slug: "technology"}
  @invalid_attrs %{}

  describe "changeset" do
    test "with valid attributes" do
      changeset = Category.changeset(%Category{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Category.changeset(%Category{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "create_changeset" do
    test "with valid attributes" do
      changeset = Category.create_changeset(%Category{}, @valid_attrs)
      assert changeset.valid?
      assert changeset.changes.slug == "technology"
    end

    test "with invalid attributes" do
      changeset = Category.create_changeset(%Category{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "does not allow duplicate slugs, regardless of case" do
      category_1_attrs = %{name: "Technology", slug: "technology", description: "Description"}
      category_2_attrs = %{name: "technology", slug: "TECHNOLOGY", description: "Description"}
      insert(:category, category_1_attrs)
      changeset = Category.create_changeset(%Category{}, category_2_attrs)
      {:error, changeset} = Repo.insert(changeset)
      refute changeset.valid?
      assert changeset.errors[:slug] == {"has already been taken", []}
    end
  end

end

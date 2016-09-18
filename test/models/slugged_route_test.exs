defmodule CodeCorps.SluggedRouteTest do
  use CodeCorps.ModelCase

  alias CodeCorps.SluggedRoute

  @valid_organization_attrs %{slug: "organization-slug", organization_id: 1}
  @valid_user_attrs %{slug: "user-slug", user_id: 1}
  @invalid_attrs %{}

  describe "changeset" do
    test "changeset with valid organization attributes" do
      changeset = SluggedRoute.changeset(%SluggedRoute{}, @valid_organization_attrs)
      assert changeset.valid?
    end

    test "changeset with valid user attributes" do
      changeset = SluggedRoute.changeset(%SluggedRoute{}, @valid_user_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = SluggedRoute.changeset(%SluggedRoute{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "create_changeset" do
    test "with valid attributes" do
      changeset = SluggedRoute.create_changeset(%SluggedRoute{}, %{slug: "CODE-CORPS", organization_id: 1})
      assert changeset.valid?
      assert changeset.changes.slug == "code-corps"
    end

    test "with invalid attributes" do
      changeset = SluggedRoute.create_changeset(%SluggedRoute{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end

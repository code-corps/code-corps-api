defmodule CodeCorps.SluggedRouteTest do
  use CodeCorps.ModelCase

  alias CodeCorps.SluggedRoute

  @valid_organization_attrs %{slug: "organization-slug", organization_id: 1}
  @valid_user_attrs %{slug: "user-slug", user_id: 1}
  @invalid_attrs %{}

  test "changeset with valid organization attributes" do
    changeset = SluggedRoute.changeset(%SluggedRoute{}, @valid_organization_attrs)
    assert changeset.valid?
  end

  test "user changeset with valid user attributes" do
    changeset = SluggedRoute.changeset(%SluggedRoute{}, @valid_user_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SluggedRoute.changeset(%SluggedRoute{}, @invalid_attrs)
    refute changeset.valid?
  end
end

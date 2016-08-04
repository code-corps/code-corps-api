defmodule CodeCorps.Validators.SlugValidatorTest do
  use ExUnit.Case, async: true

  import CodeCorps.Validators.SlugValidator

  test "with only letters" do
    changeset = process_slug("testslug") # can't be `slug` because reserved
    assert changeset.valid?
  end

  test "with prefixed underscores" do
    changeset = process_slug("_slug")
    assert changeset.valid?
  end

  test "with suffixed underscores" do
    changeset = process_slug("slug_")
    assert changeset.valid?
  end

  test "with prefixed numbers" do
    changeset = process_slug("123slug")
    assert changeset.valid?
  end

  test "with suffixed numbers" do
    changeset = process_slug("slug123")
    assert changeset.valid?
  end

  test "with multiple dashes" do
    changeset = process_slug("slug-slug-slug")
    assert changeset.valid?
  end

  test "with multiple underscores" do
    changeset = process_slug("slug_slug_slug")
    assert changeset.valid?
  end

  test "with multiple consecutive underscores" do
    changeset = process_slug("slug___slug")
    assert changeset.valid?
  end

  test "with one character" do
    changeset = process_slug("s")
    assert changeset.valid?
  end

  test "with prefixed symbols" do
    changeset = process_slug("@slug")
    refute changeset.valid?
  end

  test "with prefixed dashes" do
    changeset = process_slug("-slug")
    refute changeset.valid?
  end

  test "with suffixed dashes" do
    changeset = process_slug("slug-")
    refute changeset.valid?
  end

  test "with multiple consecutive dashes" do
    changeset = process_slug("slug---slug")
    refute changeset.valid?
  end

  test "with single slashes" do
    changeset = process_slug("slug/slug")
    refute changeset.valid?
  end

  test "with multiple slashes" do
    changeset = process_slug("slug/slug/slug")
    refute changeset.valid?
  end

  test "with multiple consecutive slashes" do
    changeset = process_slug("slug///slug")
    refute changeset.valid?
  end

  test "with reserved routes" do
    changeset = process_slug("about")
    refute changeset.valid?
  end

  defp process_slug(slug) do
    slug
    |> cast_slug
    |> validate_slug(:slug)
  end

  defp cast_slug(slug) do
    Ecto.Changeset.cast({%{slug: nil}, %{slug: :string}}, %{"slug" => slug}, [:slug])
  end
end

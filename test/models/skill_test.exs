defmodule CodeCorps.SkillTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Skill

  @valid_attrs %{description: "test", original_row: 1, slug: nil, title: "Multi Word"}
  @invalid_attrs %{description: "test", original_row: 1}
  @invalid_title %{description: "test", original_row: 1, slug: nil, title: "About"}

  test "changeset with valid attributes" do
    changeset = Skill.changeset(%Skill{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Skill.changeset(%Skill{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "title creates correct slug parameterization" do
    changeset = Skill.changeset(%Skill{}, @valid_attrs)
    assert changeset.changes.slug == "multi-word"
  end

  test "title cannot be reserved route" do
    changeset = Skill.changeset(%Skill{}, @invalid_title)
    assert changeset.errors == [slug: {"is reserved", []}]
    refute changeset.valid?
  end
end

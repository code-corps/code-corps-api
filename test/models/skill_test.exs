defmodule CodeCorps.SkillTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Skill

  @valid_attrs %{description: "some content", original_row: 42, slug: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Skill.changeset(%Skill{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Skill.changeset(%Skill{}, @invalid_attrs)
    refute changeset.valid?
  end
end

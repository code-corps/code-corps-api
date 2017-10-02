defmodule CodeCorps.SkillTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Skill

  @valid_attrs %{
    description: "Elixir is a functional, concurrent, general-purpose programming language that runs on the Erlang virtual machine (BEAM).",
    original_row: 1,
    title: "Elixir"
  }
  @invalid_attrs %{description: "test", original_row: 1}

  test "create_changeset with valid attributes" do
    changeset = Skill.create_changeset(%Skill{}, @valid_attrs)
    assert changeset.valid?
  end

  test "create_changeset with invalid attributes" do
    changeset = Skill.create_changeset(%Skill{}, @invalid_attrs)
    refute changeset.valid?
  end
end

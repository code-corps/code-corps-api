defmodule CodeCorps.Web.SkillTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Web.Skill

  @valid_attrs %{
    description: "Elixir is a functional, concurrent, general-purpose programming language that runs on the Erlang virtual machine (BEAM).",
    original_row: 1,
    title: "Elixir"
  }
  @invalid_attrs %{description: "test", original_row: 1}

  test "changeset with valid attributes" do
    changeset = Skill.changeset(%Skill{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Skill.changeset(%Skill{}, @invalid_attrs)
    refute changeset.valid?
  end
end

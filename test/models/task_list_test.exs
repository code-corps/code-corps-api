defmodule CodeCorps.TaskListTest do
  use CodeCorps.ModelCase

  alias CodeCorps.TaskList

  @valid_attrs %{name: "some content", position: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TaskList.changeset(%TaskList{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TaskList.changeset(%TaskList{}, @invalid_attrs)
    refute changeset.valid?
  end
end

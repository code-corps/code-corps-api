defmodule CodeCorps.Web.CommentTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Web.Comment

  @valid_attrs %{markdown: "I love elixir!", state: "published"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Comment.changeset(%Comment{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Comment.changeset(%Comment{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "create changeset with valid attributes" do
    attrs =
      @valid_attrs
      |> Map.put(:task_id, 1)
      |> Map.put(:user_id, 1)
    changeset = Comment.create_changeset(%Comment{}, attrs)
    assert changeset.valid?
  end

  test "create changeset with invalid attributes" do
    changeset = Comment.create_changeset(%Comment{}, @invalid_attrs)
    refute changeset.valid?
  end
end

defmodule CodeCorps.CommentTest do
  @moduledoc false

  use CodeCorps.ModelCase

  alias CodeCorps.Comment
  alias Ecto.Changeset

  @valid_attrs %{markdown: "I love elixir!", state: "published"}
  @invalid_attrs %{}

  describe "changeset/2" do
    test "with valid attributes" do
      changeset = Comment.changeset(%Comment{}, @valid_attrs)
      assert changeset.valid?
    end
  end

  describe "create_changeset/2" do
    test "with valid attributes" do
      attrs =
        @valid_attrs
        |> Map.put(:task_id, 1)
        |> Map.put(:user_id, 1)
      changeset = Comment.create_changeset(%Comment{}, attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Comment.create_changeset(%Comment{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "sets created_at and modified_at to the same time" do
      task = insert(:task)
      user = insert(:user)
      changes = Map.merge(@valid_attrs, %{
        task_id: task.id,
        user_id: user.id
      })
      changeset = Comment.create_changeset(%Comment{}, changes)
      assert changeset.valid?
      {:ok, %Comment{created_at: created_at, modified_at: modified_at}} = Repo.insert(changeset)
      assert created_at == modified_at
    end

    test "sets modified_from to 'code_corps'" do
      assert(
        %Comment{}
        |> Comment.create_changeset(%{})
        |> Changeset.get_field(:modified_from) == "code_corps"
      )
    end
  end

  describe "update_changeset/2" do
    test "sets modified_at to the new time" do
      comment = insert(:comment)
      changeset = Comment.update_changeset(comment, %{})
      assert comment.modified_at < changeset.changes[:modified_at]
    end

    test "sets modified_from to 'code_corps'" do
      assert(
        :comment
        |> insert(modified_from: "github")
        |> Comment.update_changeset(%{})
        |> Changeset.get_field(:modified_from) == "code_corps"
      )
    end
  end
end

defmodule CodeCorps.GitHub.Sync.Comment.Comment.ChangesetTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.GitHub.Sync
  alias Ecto.Changeset

  describe "create_changeset/3" do
    test "assigns proper changes to the comment" do
      task = insert(:task)
      user = insert(:user)
      github_comment = insert(:github_comment)

      changeset =
        github_comment
        |> Sync.Comment.Comment.Changeset.create_changeset(task, user)

      expected_body =
        github_comment.body
        |> Earmark.as_html!(%Earmark.Options{code_class_prefix: "language-"})

      assert changeset |> Changeset.get_change(:created_at) == github_comment.github_created_at
      assert changeset |> Changeset.get_change(:markdown) == github_comment.body
      assert changeset |> Changeset.get_change(:modified_at) == github_comment.github_updated_at
      assert changeset |> Changeset.get_change(:created_from) == "github"
      assert changeset |> Changeset.get_change(:modified_from) == "github"
      assert changeset |> Changeset.get_change(:body) == expected_body

      assert changeset.changes.github_comment.action == :update
      assert changeset.changes.github_comment.data == github_comment
      assert changeset.changes.task.action == :update
      assert changeset.changes.task.data == task
      assert changeset.changes.user.action == :update
      assert changeset.changes.user.data == user

      assert changeset.valid?
    end
  end

  describe "update_changeset/2" do
    test "assigns proper changes to the comment" do
      comment = insert(:comment)
      github_comment = insert(:github_comment)

      changeset =
        comment
        |> Sync.Comment.Comment.Changeset.update_changeset(github_comment)

      expected_body =
        github_comment.body
        |> Earmark.as_html!(%Earmark.Options{code_class_prefix: "language-"})

      assert changeset |> Changeset.get_change(:markdown) == github_comment.body
      assert changeset |> Changeset.get_change(:modified_at) == github_comment.github_updated_at
      assert changeset |> Changeset.get_field(:created_from) == "code_corps"
      assert changeset |> Changeset.get_change(:modified_from) == "github"
      assert changeset |> Changeset.get_change(:body) == expected_body
      refute changeset |> Changeset.get_change(:task)
      refute changeset |> Changeset.get_change(:github_comment)
      refute changeset |> Changeset.get_change(:user)

      assert changeset.valid?
    end

    test "validates that modified_at has not already happened" do
      # Set the modified_at in the future
      github_comment = insert(:github_comment)

      modified_at =
        github_comment.github_updated_at |> Timex.shift(days: 1)

      comment =
        :comment
        |> insert(modified_at: modified_at, github_comment: github_comment)

      changeset =
        comment
        |> Sync.Comment.Comment.Changeset.update_changeset(github_comment)

      refute changeset.valid?
      assert changeset.errors[:modified_at] ==
        {"cannot be before the last recorded time", []}
    end
  end
end

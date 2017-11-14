defmodule CodeCorps.GitHub.Sync.Comment.Comment.ChangesetTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import Ecto.Changeset

  alias CodeCorps.Comment
  alias CodeCorps.GitHub.Sync.Comment.Comment.Changeset, as: CommentChangeset

  describe "build_changeset/3" do
    test "assigns proper changes to the comment, when it's new" do
      comment = %Comment{}
      task = insert(:task)
      user = insert(:user)
      github_comment = insert(:github_comment)

      changeset = CommentChangeset.build_changeset(
        comment, github_comment, task, user
      )

      # adapted fields
      assert get_change(changeset, :created_at) == github_comment.github_created_at
      assert get_change(changeset, :markdown) == github_comment.body
      assert get_change(changeset, :modified_at) == github_comment.github_updated_at

      # manual fields
      assert get_change(changeset, :created_from) == "github"
      assert get_change(changeset, :modified_from) == "github"

      # html was rendered
      assert get_change(changeset, :body) ==
        Earmark.as_html!(github_comment.body, %Earmark.Options{code_class_prefix: "language-"})

      # relationships are proper
      assert changeset.changes.github_comment.action == :update
      assert changeset.changes.github_comment.data == github_comment
      assert changeset.changes.task.action == :update
      assert changeset.changes.task.data == task
      assert changeset.changes.user.action == :update
      assert changeset.changes.user.data == user

      assert changeset.valid?
    end

    test "assigns proper changes to the comment, when it existed previously" do
      comment = insert(:comment)
      task = insert(:task)
      user = insert(:user)
      github_comment = insert(:github_comment)

      changeset = CommentChangeset.build_changeset(
        comment, github_comment, task, user
      )

      # adapted fields
      assert get_change(changeset, :markdown) == github_comment.body
      assert get_change(changeset, :modified_at) == github_comment.github_updated_at

      # modified from is updated, but created from is unchanged
      assert get_field(changeset, :created_from) == "code_corps"
      assert get_change(changeset, :modified_from) == "github"

      # html was rendered
      assert get_change(changeset, :body) ==
        Earmark.as_html!(github_comment.body, %Earmark.Options{code_class_prefix: "language-"})

      # relationships are proper
      refute changeset |> get_change(:task)
      refute changeset |> get_change(:github_comment)
      refute changeset |> get_change(:user)

      assert changeset.valid?
    end
  end
end

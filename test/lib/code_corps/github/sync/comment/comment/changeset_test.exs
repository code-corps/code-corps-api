defmodule CodeCorps.GitHub.Sync.Comment.Comment.ChangesetTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers
  import Ecto.Changeset

  alias CodeCorps.Comment
  alias CodeCorps.GitHub.Sync.Comment.Comment.Changeset, as: CommentChangeset

  describe "build_changeset/3" do
    test "assigns proper changes to the comment, when it's new" do
      payload = load_event_fixture("issue_comment_created")
      comment = %Comment{}
      task = insert(:task)
      user = insert(:user)
      github_comment = insert(:github_comment)

      changeset = CommentChangeset.build_changeset(
        comment, payload["comment"], github_comment, task, user
      )

      {:ok, created_at, _} = payload["issue"]["created_at"] |> DateTime.from_iso8601()
      {:ok, updated_at, _} = payload["issue"]["updated_at"] |> DateTime.from_iso8601()

      # adapted fields
      assert get_change(changeset, :created_at) == created_at
      assert get_change(changeset, :markdown) == payload["comment"]["body"]
      assert get_change(changeset, :modified_at) == updated_at

      # manual fields
      assert get_change(changeset, :created_from) == "github"
      assert get_change(changeset, :modified_from) == "github"

      # html was rendered
      assert get_change(changeset, :body) ==
        Earmark.as_html!(payload["comment"]["body"], %Earmark.Options{code_class_prefix: "language-"})

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
      payload = load_event_fixture("issue_comment_created")
      comment = insert(:comment)
      task = insert(:task)
      user = insert(:user)
      github_comment = insert(:github_comment)

      changeset = CommentChangeset.build_changeset(
        comment, payload["comment"], github_comment, task, user
      )

      {:ok, updated_at, _} = payload["issue"]["updated_at"] |> DateTime.from_iso8601()

      # adapted fields
      assert get_change(changeset, :markdown) == payload["comment"]["body"]
      assert get_change(changeset, :modified_at) == updated_at

      # modified from is updated, but created from is unchanged
      assert get_field(changeset, :created_from) == "code_corps"
      assert get_change(changeset, :modified_from) == "github"

      # html was rendered
      assert get_change(changeset, :body) ==
        Earmark.as_html!(payload["comment"]["body"], %Earmark.Options{code_class_prefix: "language-"})

      # relationships are proper
      refute changeset |> get_change(:task)
      refute changeset |> get_change(:github_comment)
      refute changeset |> get_change(:user)

      assert changeset.valid?
    end

    test "validates that modified_at has not already happened" do
      payload = load_event_fixture("issue_comment_created")
      %{"comment" => %{"updated_at" => updated_at}} = payload

      # Set the modified_at in the future
      modified_at =
        updated_at
        |> Timex.parse!("{ISO:Extended:Z}")
        |> Timex.shift(days: 1)

      comment = insert(:comment, modified_at: modified_at)
      task = insert(:task)
      user = insert(:user)
      github_comment = insert(:github_comment)

      changeset = CommentChangeset.build_changeset(
        comment, payload["comment"], github_comment, task, user
      )

      refute changeset.valid?
      assert changeset.errors[:modified_at] == {"cannot be before the last recorded time", []}
    end
  end
end

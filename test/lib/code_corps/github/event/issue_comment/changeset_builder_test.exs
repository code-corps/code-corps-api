defmodule CodeCorps.GitHub.Event.IssueComment.ChangesetBuilderTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.IssueComment.ChangesetBuilder,
    Comment
  }
  alias Ecto.Changeset

  describe "build_changeset/3" do
    test "assigns proper changes to the comment, when it's new" do
      payload = load_event_fixture("issue_comment_created")
      comment = %Comment{}
      task = insert(:task)
      user = insert(:user)

      changeset = ChangesetBuilder.build_changeset(
        comment, payload, task, user
      )

      # adapted fields
      assert Changeset.get_change(changeset, :github_id) == payload["comment"]["id"]
      assert Changeset.get_change(changeset, :markdown) == payload["comment"]["body"]

      # html was rendered
      assert Changeset.get_change(changeset, :body) ==
        Earmark.as_html!(payload["comment"]["body"], %Earmark.Options{code_class_prefix: "language-"})

      # relationships are proper
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

      changeset = ChangesetBuilder.build_changeset(
        comment, payload, task, user
      )

      # adapted fields
      assert Changeset.get_change(changeset, :github_id) == payload["comment"]["id"]
      assert Changeset.get_change(changeset, :markdown) == payload["comment"]["body"]

      # html was rendered
      assert Changeset.get_change(changeset, :body) ==
        Earmark.as_html!(payload["comment"]["body"], %Earmark.Options{code_class_prefix: "language-"})

      # relationships are proper
      refute changeset |> Changeset.get_change(:task)
      refute changeset |> Changeset.get_change(:user)

      assert changeset.valid?
    end
  end
end

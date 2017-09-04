defmodule CodeCorps.GitHub.Event.IssueComment.ChangesetBuilderTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers
  import Ecto.Changeset

  alias CodeCorps.{
    GitHub.Event.IssueComment.ChangesetBuilder,
    Comment
  }

  describe "build_changeset/3" do
    test "assigns proper changes to the task" do
      payload = load_event_fixture("issue_comment_created")
      comment = %Comment{}
      task = insert(:task)
      user = insert(:user)

      changeset = ChangesetBuilder.build_changeset(
        comment, payload, task, user
      )

      # adapted fields
      assert get_change(changeset, :github_id) == payload["comment"]["id"]
      assert get_change(changeset, :markdown) == payload["comment"]["body"]

      # html was rendered
      assert get_change(changeset, :body) ==
        Earmark.as_html!(payload["comment"]["body"], %Earmark.Options{code_class_prefix: "language-"})

      # relationships are proper
      assert get_change(changeset, :task_id) == task.id
      assert get_change(changeset, :user_id) == user.id

      assert changeset.valid?
    end
  end
end

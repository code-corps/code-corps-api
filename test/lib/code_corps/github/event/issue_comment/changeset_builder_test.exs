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
    test "assigns proper changes to the comment, when it's new" do
      payload = load_event_fixture("issue_comment_created")
      comment = %Comment{}
      task = insert(:task)
      user = insert(:user)

      changeset = ChangesetBuilder.build_changeset(
        comment, payload, task, user
      )

      {:ok, created_at, _} = payload["issue"]["created_at"] |> DateTime.from_iso8601()
      {:ok, updated_at, _} = payload["issue"]["updated_at"] |> DateTime.from_iso8601()

      # adapted fields
      assert get_change(changeset, :created_at) == created_at
      assert get_change(changeset, :github_id) == payload["comment"]["id"]
      assert get_change(changeset, :markdown) == payload["comment"]["body"]
      assert get_change(changeset, :modified_at) == updated_at

      # manual fields
      assert get_change(changeset, :created_from) == "github"
      assert get_change(changeset, :modified_from) == "github"

      # html was rendered
      assert get_change(changeset, :body) ==
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

      {:ok, updated_at, _} = payload["issue"]["updated_at"] |> DateTime.from_iso8601()

      # adapted fields
      assert get_change(changeset, :github_id) == payload["comment"]["id"]
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
      refute changeset |> get_change(:user)

      assert changeset.valid?
    end
  end
end

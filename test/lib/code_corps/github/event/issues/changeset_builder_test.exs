defmodule CodeCorps.GitHub.Event.Issues.ChangesetBuilderTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.{Factories, TestHelpers.GitHub}
  import Ecto.Changeset

  alias CodeCorps.{
    GitHub.Event.Issues.ChangesetBuilder,
    GitHub.Event.Issues.StateMapper,
    Task
  }

  describe "build_changeset/3" do
    test "assigns proper changes to the task" do
      payload = load_event_fixture("issues_opened")
      task = %Task{}
      project_github_repo = insert(:project_github_repo)
      user = insert(:user)

      changeset = ChangesetBuilder.build_changeset(
        task, payload, project_github_repo, user
      )

      # adapted fields
      assert get_change(changeset, :name) == payload["issue"]["name"]
      assert get_change(changeset, :github_id) == payload["issue"]["id"]
      assert get_change(changeset, :markdown) == payload["issue"]["body"]
      assert get_field(changeset, :status) == payload["issue"]["state"]

      # html was rendered
      assert get_change(changeset, :body) ==
        Earmark.as_html!(payload["issue"]["body"], %Earmark.Options{code_class_prefix: "language-"})

      # relationships are proper
      assert get_change(changeset, :project_id) == project_github_repo.project_id
      assert get_change(changeset, :user_id) == user.id

      # state was computed
      assert get_change(changeset, :state) == StateMapper.get_state(payload)

      assert changeset.valid?
    end
  end
end

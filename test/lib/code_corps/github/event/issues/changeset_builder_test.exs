defmodule CodeCorps.GitHub.Event.Issues.ChangesetBuilderTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers
  import Ecto.Changeset

  alias CodeCorps.{
    GitHub.Event.Issues.ChangesetBuilder,
    Task
  }

  describe "build_changeset/3" do
    test "assigns proper changes to the task" do
      payload = load_event_fixture("issues_opened")
      task = %Task{}
      project = insert(:project)
      project_github_repo = insert(:project_github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, inbox: true)

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
      assert get_change(changeset, :task_list_id) == task_list.id
      assert get_change(changeset, :user_id) == user.id

      assert changeset.valid?
    end
  end
end

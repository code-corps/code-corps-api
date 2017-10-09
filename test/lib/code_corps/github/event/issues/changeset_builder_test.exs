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

      {:ok, created_at, _} = payload["issue"]["created_at"] |> DateTime.from_iso8601()
      {:ok, updated_at, _} = payload["issue"]["updated_at"] |> DateTime.from_iso8601()

      # adapted fields
      assert get_change(changeset, :created_at) == created_at
      assert get_change(changeset, :github_issue_number) == payload["issue"]["number"]
      assert get_change(changeset, :markdown) == payload["issue"]["body"]
      assert get_change(changeset, :modified_at) == updated_at
      assert get_change(changeset, :name) == payload["issue"]["name"]
      assert get_field(changeset, :status) == payload["issue"]["state"]

      # manual fields
      assert get_change(changeset, :created_from) == "github"
      assert get_change(changeset, :modified_from) == "github"

      # markdown was rendered into html
      assert get_change(changeset, :body) ==
        payload["issue"]["body"]
        |> Earmark.as_html!(%Earmark.Options{code_class_prefix: "language-"})

      # relationships are proper
      assert get_change(changeset, :github_repo_id) == project_github_repo.github_repo_id
      assert get_change(changeset, :project_id) == project_github_repo.project_id
      assert get_change(changeset, :task_list_id) == task_list.id
      assert get_change(changeset, :user_id) == user.id

      assert changeset.valid?
    end
  end
end

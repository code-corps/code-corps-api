defmodule CodeCorps.GitHub.Sync.Issue.Task.ChangesetTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers
  import Ecto.Changeset

  alias CodeCorps.Task
  alias CodeCorps.GitHub.Sync.Issue.Task.Changeset, as: TaskChangeset

  describe "build_changeset/3" do
    test "assigns proper changes to the task" do
      %{"issue" => issue} = load_event_fixture("issues_opened")
      task = %Task{}
      github_issue = insert(:github_issue)
      project = insert(:project)
      project_github_repo = insert(:project_github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, inbox: true)

      changeset = TaskChangeset.build_changeset(
        task, issue, github_issue, project_github_repo, user
      )

      {:ok, created_at, _} = issue["created_at"] |> DateTime.from_iso8601()
      {:ok, updated_at, _} = issue["updated_at"] |> DateTime.from_iso8601()

      # adapted fields
      assert get_change(changeset, :created_at) == created_at
      assert get_change(changeset, :markdown) == issue["body"]
      assert get_change(changeset, :modified_at) == updated_at
      assert get_change(changeset, :name) == issue["name"]
      assert get_field(changeset, :status) == issue["state"]

      # manual fields
      assert get_change(changeset, :created_from) == "github"
      assert get_change(changeset, :modified_from) == "github"

      # markdown was rendered into html
      assert get_change(changeset, :body) ==
        issue["body"]
        |> Earmark.as_html!(%Earmark.Options{code_class_prefix: "language-"})

      # relationships are proper
      assert get_change(changeset, :github_issue_id) == github_issue.id
      assert get_change(changeset, :github_repo_id) == project_github_repo.github_repo_id
      assert get_change(changeset, :project_id) == project_github_repo.project_id
      assert get_change(changeset, :task_list_id) == task_list.id
      assert get_change(changeset, :user_id) == user.id

      assert changeset.valid?
      assert changeset.changes[:position]
    end

    test "validates that modified_at has not already happened" do
      %{"issue" => issue} = load_event_fixture("issues_opened")
      %{"updated_at" => updated_at} = issue

      # Set the modified_at in the future
      modified_at =
        updated_at
        |> Timex.parse!("{ISO:Extended:Z}")
        |> Timex.shift(days: 1)

      project = insert(:project)
      github_issue = insert(:github_issue)
      github_repo = insert(:github_repo)
      project_github_repo = insert(:project_github_repo, github_repo: github_repo, project: project)
      user = insert(:user)
      task = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo, user: user, modified_at: modified_at)

      changeset = TaskChangeset.build_changeset(
        task, issue, github_issue, project_github_repo, user
      )

      refute changeset.valid?
      assert changeset.errors[:modified_at] == {"cannot be before the last recorded time", []}
    end
  end
end

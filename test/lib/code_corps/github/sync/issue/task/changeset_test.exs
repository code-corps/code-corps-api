defmodule CodeCorps.GitHub.Sync.Issue.Task.ChangesetTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import Ecto.Changeset

  alias CodeCorps.Task
  alias CodeCorps.GitHub.Sync.Issue.Task.Changeset, as: TaskChangeset

  describe "build_changeset/3" do
    test "assigns proper changes to the task" do
      task = %Task{}
      github_issue = insert(
        :github_issue,
        github_created_at: DateTime.utc_now |> Timex.shift(minutes: 1),
        github_updated_at: DateTime.utc_now |> Timex.shift(hours: 1))
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, inbox: true)

      changeset = TaskChangeset.build_changeset(
        task, github_issue, github_repo, user
      )

      # adapted fields
      assert get_change(changeset, :created_at) == github_issue.github_created_at
      assert get_change(changeset, :markdown) == github_issue.body
      assert get_change(changeset, :modified_at) == github_issue.github_updated_at
      assert get_change(changeset, :title) == github_issue.title
      assert get_field(changeset, :status) == github_issue.state

      # manual fields
      assert get_change(changeset, :created_from) == "github"
      assert get_change(changeset, :modified_from) == "github"

      # markdown was rendered into html
      assert get_change(changeset, :body) ==
        github_issue.body
        |> Earmark.as_html!(%Earmark.Options{code_class_prefix: "language-"})

      # relationships are proper
      assert get_change(changeset, :github_issue_id) == github_issue.id
      assert get_change(changeset, :github_repo_id) == github_repo.id
      assert get_change(changeset, :project_id) == github_repo.project_id
      assert get_change(changeset, :task_list_id) == task_list.id
      assert get_change(changeset, :user_id) == user.id

      assert changeset.changes[:position]
      assert changeset |> get_field(:archived) == false

      assert changeset.valid?
    end

    test "assigns task to inbox list if github issue is open" do
      task = %Task{}
      github_issue = insert(:github_issue, state: "open")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, inbox: true)

      changeset = TaskChangeset.build_changeset(
        task, github_issue, github_repo, user
      )

      assert get_change(changeset, :task_list_id) == task_list.id
    end

    test "assigns task to pull request list if github issue is associated with pull request" do
      task = %Task{}
      github_pull_request = insert(:github_pull_request)
      github_issue = insert(:github_issue, github_pull_request: github_pull_request, state: "open")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, pull_requests: true)

      changeset = TaskChangeset.build_changeset(
        task, github_issue, github_repo, user
      )

      assert get_change(changeset, :task_list_id) == task_list.id
    end

    test "assigns task to 'done' list if github issue is closed" do
      task = %Task{}
      github_issue = insert(:github_issue, state: "closed")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, done: true)

      changeset = TaskChangeset.build_changeset(
        task, github_issue, github_repo, user
      )

      assert get_change(changeset, :task_list_id) == task_list.id
    end

    test "assigns task to 'done' list if github issue is closed and associated to pull request" do
      task = %Task{}
      github_pull_request = insert(:github_pull_request)
      github_issue = insert(:github_issue, github_pull_request: github_pull_request, state: "closed")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, done: true)

      changeset = TaskChangeset.build_changeset(
        task, github_issue, github_repo, user
      )

      assert get_change(changeset, :task_list_id) == task_list.id
    end

    test "archives task and removes from task list if issue is closed and unmodified for over a month" do
      over_a_month_ago = Timex.now |> Timex.shift(days: -35)

      task = %Task{}
      github_pull_request = insert(:github_pull_request)
      github_issue = insert(
        :github_issue,
        github_pull_request: github_pull_request,
        state: "closed",
        github_updated_at: over_a_month_ago)

      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      insert(:task_list, project: project, done: true)

      changeset = TaskChangeset.build_changeset(
        task, github_issue, github_repo, user
      )

      assert get_field(changeset, :archived) == true
      assert get_field(changeset, :task_list_id) == nil
    end

    test "validates that modified_at has not already happened" do
      project = insert(:project)
      github_issue = insert(:github_issue, github_updated_at: DateTime.utc_now |> Timex.shift(minutes: -1), state: "open")
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo, user: user, modified_at: DateTime.utc_now)
      insert(:task_list, project: project, inbox: true)

      changeset = TaskChangeset.build_changeset(
        task, github_issue, github_repo, user
      )

      refute changeset.valid?
      assert changeset.errors[:modified_at] == {"cannot be before the last recorded time", []}
    end
  end
end

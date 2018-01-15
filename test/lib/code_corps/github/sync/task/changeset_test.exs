defmodule CodeCorps.GitHub.Sync.Task.ChangesetTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.GitHub.Sync.Task
  alias Ecto.Changeset

  describe "create_changeset/4" do
    test "assigns proper changes to the task" do
      github_issue = insert(
        :github_issue,
        github_created_at: DateTime.utc_now |> Timex.shift(minutes: 1),
        github_updated_at: DateTime.utc_now |> Timex.shift(hours: 1))
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, inbox: true)

      changeset =
        github_issue |> Task.Changeset.create_changeset(github_repo, user)

      assert changeset |> Changeset.get_change(:created_at) == github_issue.github_created_at
      assert changeset |> Changeset.get_change(:markdown) == github_issue.body
      assert changeset |> Changeset.get_change(:modified_at) == github_issue.github_updated_at
      assert changeset |> Changeset.get_change(:title) == github_issue.title
      assert changeset |> Changeset.get_field(:status) == github_issue.state
      assert changeset |> Changeset.get_change(:created_from) == "github"
      assert changeset |> Changeset.get_change(:modified_from) == "github"
      assert changeset |> Changeset.get_change(:github_issue) |> Map.get(:data) == github_issue
      assert changeset |> Changeset.get_change(:github_repo) |> Map.get(:data) == github_repo
      assert changeset |> Changeset.get_change(:project_id) == github_repo.project_id
      assert changeset |> Changeset.get_change(:task_list_id) == task_list.id
      assert changeset |> Changeset.get_change(:user) |> Map.get(:data) == user
      assert changeset |> Changeset.get_change(:position)
      assert changeset |> Changeset.get_field(:archived) == false

      expected_body =
        github_issue.body
        |> Earmark.as_html!(%Earmark.Options{code_class_prefix: "language-"})
      assert Changeset.get_change(changeset, :body) == expected_body

      assert changeset.valid?
    end

    test "assigns task to inbox list if github issue is open" do
      github_issue = insert(:github_issue, state: "open")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, inbox: true)

      changeset =
        github_issue |> Task.Changeset.create_changeset(github_repo, user)

      assert changeset |> Changeset.get_change(:task_list_id) == task_list.id
    end

    test "assigns task to pull request list if github issue is associated with pull request" do
      github_pull_request = insert(:github_pull_request)
      github_issue = insert(:github_issue, github_pull_request: github_pull_request, state: "open")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, pull_requests: true)

      changeset =
        github_issue |> Task.Changeset.create_changeset(github_repo, user)

      assert changeset |> Changeset.get_change(:task_list_id) == task_list.id
    end

    test "assigns task to 'done' list if github issue is closed" do
      github_issue = insert(:github_issue, state: "closed")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, done: true)

      changeset =
        github_issue |> Task.Changeset.create_changeset(github_repo, user)

      assert changeset |> Changeset.get_change(:task_list_id) == task_list.id
    end

    test "assigns task to 'done' list if github issue is closed and associated to pull request" do
      github_pull_request = insert(:github_pull_request)
      github_issue = insert(:github_issue, github_pull_request: github_pull_request, state: "closed")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, done: true)

      changeset =
        github_issue |> Task.Changeset.create_changeset(github_repo, user)

      assert changeset |> Changeset.get_change(:task_list_id) == task_list.id
    end

    test "archives task and removes from task list if issue is closed and unmodified for over a month" do
      over_a_month_ago = Timex.now |> Timex.shift(days: -35)

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

      changeset =
        github_issue |> Task.Changeset.create_changeset(github_repo, user)

      assert changeset |> Changeset.get_field(:archived) == true
      assert changeset |> Changeset.get_field(:task_list_id) == nil
    end
  end

  describe "update_changeset/3" do
    test "assigns proper changes to the task" do
      github_issue = insert(
        :github_issue,
        github_created_at: DateTime.utc_now |> Timex.shift(minutes: 1),
        github_updated_at: DateTime.utc_now |> Timex.shift(hours: 1))
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task_list = insert(:task_list, project: project, inbox: true)
      task = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo, user: user, modified_at: DateTime.utc_now)

      changeset =
        task |> Task.Changeset.update_changeset(github_issue, github_repo)

      assert changeset |> Changeset.get_change(:markdown) == github_issue.body
      assert changeset |> Changeset.get_change(:modified_at) == github_issue.github_updated_at
      assert changeset |> Changeset.get_change(:title) == github_issue.title
      assert changeset |> Changeset.get_field(:status) == github_issue.state
      refute changeset |> Changeset.get_change(:created_from)
      assert changeset |> Changeset.get_change(:modified_from) == "github"
      assert changeset |> Changeset.get_change(:task_list_id) == task_list.id
      assert changeset |> Changeset.get_change(:position)
      assert changeset |> Changeset.get_field(:archived) == false

      expected_body =
        github_issue.body
        |> Earmark.as_html!(%Earmark.Options{code_class_prefix: "language-"})
      assert Changeset.get_change(changeset, :body) == expected_body

      assert changeset.valid?
    end

    test "validates that modified_at has not already happened" do
      project = insert(:project)
      github_issue = insert(:github_issue, github_updated_at: DateTime.utc_now |> Timex.shift(minutes: -1), state: "open")
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo, user: user, modified_at: DateTime.utc_now)
      insert(:task_list, project: project, inbox: true)

      changeset =
        task |> Task.Changeset.update_changeset(github_issue, github_repo)

      refute changeset.valid?
      assert changeset.errors[:modified_at] == {"cannot be before the last recorded time", []}
    end

    test "assigns task to inbox list if github issue is open" do
      github_issue = insert(:github_issue, state: "open")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo, user: user, modified_at: DateTime.utc_now)
      task_list = insert(:task_list, project: project, inbox: true)

      changeset =
        task |> Task.Changeset.update_changeset(github_issue, github_repo)

      assert changeset |> Changeset.get_change(:task_list_id) == task_list.id
    end

    test "assigns task to pull request list if github issue is associated with pull request" do
      github_pull_request = insert(:github_pull_request)
      github_issue = insert(:github_issue, github_pull_request: github_pull_request, state: "open")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo, user: user, modified_at: DateTime.utc_now)
      task_list = insert(:task_list, project: project, pull_requests: true)

      changeset =
        task |> Task.Changeset.update_changeset(github_issue, github_repo)

      assert changeset |> Changeset.get_change(:task_list_id) == task_list.id
    end

    test "assigns task to 'done' list if github issue is closed" do
      github_issue = insert(:github_issue, state: "closed")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo, user: user, modified_at: DateTime.utc_now)
      task_list = insert(:task_list, project: project, done: true)

      changeset =
        task |> Task.Changeset.update_changeset(github_issue, github_repo)

      assert changeset |> Changeset.get_change(:task_list_id) == task_list.id
    end

    test "assigns task to 'done' list if github issue is closed and associated to pull request" do
      github_pull_request = insert(:github_pull_request)
      github_issue = insert(:github_issue, github_pull_request: github_pull_request, state: "closed")
      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo, user: user, modified_at: DateTime.utc_now)
      task_list = insert(:task_list, project: project, done: true)

      changeset =
        task |> Task.Changeset.update_changeset(github_issue, github_repo)

      assert changeset |> Changeset.get_change(:task_list_id) == task_list.id
    end

    test "archives task and removes from task list if issue is closed and unmodified for over a month" do
      over_a_month_ago = Timex.now |> Timex.shift(days: -35)

      github_pull_request = insert(:github_pull_request)
      github_issue = insert(
        :github_issue,
        github_pull_request: github_pull_request,
        state: "closed",
        github_updated_at: over_a_month_ago)

      project = insert(:project)
      github_repo = insert(:github_repo, project: project)
      user = insert(:user)
      task = insert(:task, project: project, github_issue: github_issue, github_repo: github_repo, user: user, modified_at: DateTime.utc_now)
      insert(:task_list, project: project, done: true)

      changeset =
        task |> Task.Changeset.update_changeset(github_issue, github_repo)

      assert changeset |> Changeset.get_field(:archived) == true
      assert changeset |> Changeset.get_field(:task_list_id) == nil
    end
  end
end

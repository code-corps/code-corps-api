defmodule CodeCorps.GitHub.Event.IssuesTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.Issues,
    Project,
    Repo,
    Task,
    User
  }

  describe "handle/2" do
    @payload load_event_fixture("issues_opened") |> Map.put("action", "foo")

    test "returns error if action of the event is wrong" do
      assert {:error, :unexpected_action} == Issues.handle(@payload)
    end
  end

  describe "handle/2 for Issues::opened" do
    @payload load_event_fixture("issues_opened")

    test "with unmatched user, passes with no changes made if no matching projects" do
      %{
        "issue" => %{
          "user" => %{"id" => user_github_id}
        },
        "repository" => %{"id" => repo_github_id}
      } = @payload

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
      refute Repo.get_by(User, github_id: user_github_id)
    end

    test "with unmatched user, creates user, creates task for each project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "number" => number,
          "user" => %{"id" => user_github_id}
        },
        "repository" => %{"id" => repo_github_id}
      } = @payload

      github_repo = insert(:github_repo, github_id: repo_github_id)

      project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      {:ok, tasks} = Issues.handle(@payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue_number == number
        assert task.status == "open"
      end)
    end

    test "with unmatched user, returns error if unmatched repository" do
      assert Issues.handle(@payload) == {:error, :repository_not_found}
      refute Repo.one(User)
    end

    test "with matched user, passes with no changes made if no matching projects" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}, "repository" => %{"id" => repo_github_id}} = @payload
      insert(:user, github_id: user_github_id)

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
    end

    test "with matched user, creates or updates task for each project associated to github repo" do
      %{
        "issue" => %{"body" => markdown, "title" => title, "number" => number, "user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)

      [%{project: project} | _rest] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      %{id: existing_task_id} =
        insert(:task, project: project, user: user, github_repo: github_repo, github_issue_number: number)

      {:ok, tasks} = Issues.handle(@payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue_number == number
        assert task.status == "open"
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "with matched user, returns error if unmatched repository" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}} = @payload
      insert(:user, github_id: user_github_id)

      assert Issues.handle(@payload) == {:error, :repository_not_found}
    end

    test "returns error if payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(%{})
    end

    test "returns error if repo payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@payload |> Map.put("repository", "foo"))
    end

    test "returns error if issue payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@payload |> Map.put("issue", "foo"))
    end
  end

  describe "handle/2 for Issues::closed" do
    @payload load_event_fixture("issues_closed")

    test "with unmatched user, passes with no changes made if no matching projects" do
      %{
        "issue" => %{"user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
      refute Repo.get_by(User, github_id: user_github_id)
    end

    test "with unmatched user, creates user, creates task for each project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "number" => number,
          "user" => %{"id" => user_github_id}
        },
        "repository" => %{"id" => repo_github_id}
      } = @payload

      github_repo = insert(:github_repo, github_id: repo_github_id)

      project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      {:ok, tasks} = Issues.handle(@payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue_number == number
        assert task.status == "closed"
      end)
    end

    test "with unmatched user, returns error if unmatched repository" do
      assert Issues.handle(@payload) == {:error, :repository_not_found}
      refute Repo.one(User)
    end

    test "with matched user, passes with no changes made if no matching projects" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}, "repository" => %{"id" => repo_github_id}} = @payload
      insert(:user, github_id: user_github_id)

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
    end

    test "with matched user, creates or updates task for each project associated to github repo" do
      %{
        "issue" => %{"body" => markdown, "title" => title, "number" => number, "user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)

      [%{project: project} | _rest] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      %{id: existing_task_id} =
        insert(:task, project: project, user: user, github_repo: github_repo, github_issue_number: number)

      {:ok, tasks} = Issues.handle(@payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue_number == number
        assert task.status == "closed"
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "with matched user, returns error if unmatched repository" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}} = @payload
      insert(:user, github_id: user_github_id)

      assert Issues.handle(@payload) == {:error, :repository_not_found}
    end

    test "returns error if payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(%{})
    end

    test "returns error if repo payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@payload |> Map.put("repository", "foo"))
    end

    test "returns error if issue payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@payload |> Map.put("issue", "foo"))
    end
  end

  describe "handle/2 for Issues::edited" do
    @payload load_event_fixture("issues_edited")

    test "with unmatched user, passes with no changes made if no matching projects" do
      %{
        "issue" => %{"user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
      refute Repo.get_by(User, github_id: user_github_id)
    end

    test "with unmatched user, creates user, creates task for each project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "number" => number,
          "user" => %{"id" => user_github_id}
        },
        "repository" => %{"id" => repo_github_id}
      } = @payload

      github_repo = insert(:github_repo, github_id: repo_github_id)

      project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      {:ok, tasks} = Issues.handle(@payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue_number == number
        assert task.status == "open"
      end)
    end

    test "with unmatched user, returns error if unmatched repository" do
      assert Issues.handle(@payload) == {:error, :repository_not_found}
      refute Repo.one(User)
    end

    test "with matched user, passes with no changes made if no matching projects" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}, "repository" => %{"id" => repo_github_id}} = @payload
      insert(:user, github_id: user_github_id)

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
    end

    test "with matched user, creates or updates task for each project associated to github repo" do
      %{
        "issue" => %{"body" => markdown, "title" => title, "number" => number, "user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)

      [%{project: project} | _rest] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      %{id: existing_task_id} =
        insert(:task, project: project, user: user, github_repo: github_repo, github_issue_number: number)

      {:ok, tasks} = Issues.handle(@payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue_number == number
        assert task.status == "open"
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "with matched user, returns error if unmatched repository" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}} = @payload
      insert(:user, github_id: user_github_id)

      assert Issues.handle(@payload) == {:error, :repository_not_found}
    end

    test "returns error if payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(%{})
    end

    test "returns error if repo payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@payload |> Map.put("repository", "foo"))
    end

    test "returns error if issue payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@payload |> Map.put("issue", "foo"))
    end
  end

  describe "handle/2 for Issues::reopened" do
    @payload load_event_fixture("issues_reopened")

    test "with unmatched user, passes with no changes made if no matching projects" do
      %{
        "issue" => %{"user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
      refute Repo.get_by(User, github_id: user_github_id)
    end

    test "with unmatched user, creates user, creates task for each project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "number" => number,
          "user" => %{"id" => user_github_id}
        },
        "repository" => %{"id" => repo_github_id}
      } = @payload

      github_repo = insert(:github_repo, github_id: repo_github_id)

      project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      {:ok, tasks} = Issues.handle(@payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.github_repo_id == github_repo.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue_number == number
        assert task.status == "open"
      end)
    end

    test "with unmatched user, returns error if unmatched repository" do
      assert Issues.handle(@payload) == {:error, :repository_not_found}
      refute Repo.one(User)
    end

    test "with matched user, passes with no changes made if no matching projects" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}, "repository" => %{"id" => repo_github_id}} = @payload
      insert(:user, github_id: user_github_id)

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
    end

    test "with matched user, creates or updates task for each project associated to github repo" do
      %{
        "issue" => %{"body" => markdown, "title" => title, "number" => number, "user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)

      [%{project: project} | _rest] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      project_ids |> Enum.each(fn project_id ->
        project = Project |> Repo.get_by(id: project_id)
        insert(:task_list, project: project, inbox: true)
      end)

      %{id: existing_task_id} =
        insert(:task, project: project, user: user, github_repo: github_repo, github_issue_number: number)

      {:ok, tasks} = Issues.handle(@payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.project_id in project_ids
        assert task.github_repo_id == github_repo.id
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_issue_number == number
        assert task.status == "open"
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "with matched user, returns error if unmatched repository" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}} = @payload
      insert(:user, github_id: user_github_id)

      assert Issues.handle(@payload) == {:error, :repository_not_found}
    end

    test "returns error if payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(%{})
    end

    test "returns error if repo payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@payload |> Map.put("repository", "foo"))
    end

    test "returns error if issue payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@payload |> Map.put("issue", "foo"))
    end
  end

  @unimplemented_actions ~w(assigned unassigned labeled unlabeled milestoned demilestoned)

  @unimplemented_actions |> Enum.each(fn action ->
    describe "handle/2 for Issues::#{action}" do
      @payload %{
        "action" => action,
        "issue" => %{
          "id" => 1, "title" => "foo", "body" => "bar", "state" => "baz",
          "user" => %{"id" => "bat"}
        },
        "repository" => %{"id" => 2}
      }

      test "is not implemented" do
        assert Issues.handle(@payload) == {:error, :not_fully_implemented}
      end
    end
  end)
end

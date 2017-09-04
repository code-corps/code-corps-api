defmodule CodeCorps.GitHub.Event.IssuesTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.Issues,
    Repo,
    Task,
    User
  }

  describe "handle/2" do
    @payload load_event_fixture("issues_opened")

    test "returns error if action of the event is wrong" do
      event = build(:github_event, action: "foo", type: "issues")
      assert {:error, :unexpected_action} == Issues.handle(event, @payload)
    end
  end

  describe "handle/2 for Issues::opened" do
    @payload load_event_fixture("issues_opened")
    @event build(:github_event, action: "opened", type: "issues")

    test "with unmatched user, passes with no changes made if no matching projects" do
      %{"repository" => %{"id" => repo_github_id}} = @payload

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@event, @payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
      refute Repo.one(User)
    end

    test "with unmatched user, creates user, creates task for each project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "id" => github_id,
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

      {:ok, tasks} = Issues.handle(@event, @payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_id == github_id
        assert task.status == "open"
      end)
    end

    test "with unmatched user, returns error if unmatched repository" do
      assert Issues.handle(@event, @payload) == {:error, :unmatched_repository}
      refute Repo.one(User)
    end

    test "with matched user, passes with no changes made if no matching projects" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}, "repository" => %{"id" => repo_github_id}} = @payload
      insert(:user, github_id: user_github_id)

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@event, @payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
    end

    test "with matched user, creates or updates task for each project associated to github repo" do
      %{
        "issue" => %{"body" => markdown, "title" => title, "id" => github_id, "user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)

      [%{project: project} | _rest] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      %{id: existing_task_id} = insert(:task, project: project, user: user, github_id: github_id)

      {:ok, tasks} = Issues.handle(@event, @payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_id == github_id
        assert task.status == "open"
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "with matched user, returns error if unmatched repository" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}} = @payload
      insert(:user, github_id: user_github_id)

      assert Issues.handle(@event, @payload) == {:error, :unmatched_repository}
    end

    test "returns error if payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, %{})
    end

    test "returns error if repo payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, @payload |> Map.put("repository", "foo"))
    end

    test "returns error if issue payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, @payload |> Map.put("issue", "foo"))
    end
  end

  describe "handle/2 for Issues::closed" do
    @payload load_event_fixture("issues_closed")
    @event build(:github_event, action: "closed", type: "issues")

    test "with unmatched user, passes with no changes made if no matching projects" do
      %{"repository" => %{"id" => repo_github_id}} = @payload

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@event, @payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
      refute Repo.one(User)
    end

    test "with unmatched user, creates user, creates task for each project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "id" => github_id,
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

      {:ok, tasks} = Issues.handle(@event, @payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_id == github_id
        assert task.status == "closed"
      end)
    end

    test "with unmatched user, returns error if unmatched repository" do
      assert Issues.handle(@event, @payload) == {:error, :unmatched_repository}
      refute Repo.one(User)
    end

    test "with matched user, passes with no changes made if no matching projects" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}, "repository" => %{"id" => repo_github_id}} = @payload
      insert(:user, github_id: user_github_id)

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@event, @payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
    end

    test "with matched user, creates or updates task for each project associated to github repo" do
      %{
        "issue" => %{"body" => markdown, "title" => title, "id" => github_id, "user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)

      [%{project: project} | _rest] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      %{id: existing_task_id} = insert(:task, project: project, user: user, github_id: github_id)

      {:ok, tasks} = Issues.handle(@event, @payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_id == github_id
        assert task.status == "closed"
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "with matched user, returns error if unmatched repository" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}} = @payload
      insert(:user, github_id: user_github_id)

      assert Issues.handle(@event, @payload) == {:error, :unmatched_repository}
    end

    test "returns error if payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, %{})
    end

    test "returns error if repo payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, @payload |> Map.put("repository", "foo"))
    end

    test "returns error if issue payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, @payload |> Map.put("issue", "foo"))
    end
  end

  describe "handle/2 for Issues::edited" do
    @payload load_event_fixture("issues_edited")
    @event build(:github_event, action: "edited", type: "issues")

    test "with unmatched user, passes with no changes made if no matching projects" do
      %{"repository" => %{"id" => repo_github_id}} = @payload

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@event, @payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
      refute Repo.one(User)
    end

    test "with unmatched user, creates user, creates task for each project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "id" => github_id,
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

      {:ok, tasks} = Issues.handle(@event, @payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_id == github_id
        assert task.status == "open"
      end)
    end

    test "with unmatched user, returns error if unmatched repository" do
      assert Issues.handle(@event, @payload) == {:error, :unmatched_repository}
      refute Repo.one(User)
    end

    test "with matched user, passes with no changes made if no matching projects" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}, "repository" => %{"id" => repo_github_id}} = @payload
      insert(:user, github_id: user_github_id)

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@event, @payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
    end

    test "with matched user, creates or updates task for each project associated to github repo" do
      %{
        "issue" => %{"body" => markdown, "title" => title, "id" => github_id, "user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)

      [%{project: project} | _rest] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      %{id: existing_task_id} = insert(:task, project: project, user: user, github_id: github_id)

      {:ok, tasks} = Issues.handle(@event, @payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_id == github_id
        assert task.status == "open"
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "with matched user, returns error if unmatched repository" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}} = @payload
      insert(:user, github_id: user_github_id)

      assert Issues.handle(@event, @payload) == {:error, :unmatched_repository}
    end

    test "returns error if payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, %{})
    end

    test "returns error if repo payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, @payload |> Map.put("repository", "foo"))
    end

    test "returns error if issue payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, @payload |> Map.put("issue", "foo"))
    end
  end

  describe "handle/2 for Issues::reopened" do
    @payload load_event_fixture("issues_reopened")
    @event build(:github_event, action: "reopened", type: "issues")

    test "with unmatched user, passes with no changes made if no matching projects" do
      %{"repository" => %{"id" => repo_github_id}} = @payload

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@event, @payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
      refute Repo.one(User)
    end

    test "with unmatched user, creates user, creates task for each project associated to github repo" do
      %{
        "issue" => %{
          "body" => markdown, "title" => title, "id" => github_id,
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

      {:ok, tasks} = Issues.handle(@event, @payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      user = Repo.get_by(User, github_id: user_github_id)
      assert user

      tasks |> Enum.each(fn task ->
        assert task.user_id == user.id
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_id == github_id
        assert task.status == "open"
      end)
    end

    test "with unmatched user, returns error if unmatched repository" do
      assert Issues.handle(@event, @payload) == {:error, :unmatched_repository}
      refute Repo.one(User)
    end

    test "with matched user, passes with no changes made if no matching projects" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}, "repository" => %{"id" => repo_github_id}} = @payload
      insert(:user, github_id: user_github_id)

      insert(:github_repo, github_id: repo_github_id)
      assert Issues.handle(@event, @payload) == {:ok, []}
      assert Repo.aggregate(Task, :count, :id) == 0
    end

    test "with matched user, creates or updates task for each project associated to github repo" do
      %{
        "issue" => %{"body" => markdown, "title" => title, "id" => github_id, "user" => %{"id" => user_github_id}},
        "repository" => %{"id" => repo_github_id}
      } = @payload

      user = insert(:user, github_id: user_github_id)

      github_repo = insert(:github_repo, github_id: repo_github_id)

      [%{project: project} | _rest] = project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

      project_ids =
        project_github_repos
        |> Enum.map(&Map.get(&1, :project))
        |> Enum.map(&Map.get(&1, :id))

      %{id: existing_task_id} = insert(:task, project: project, user: user, github_id: github_id)

      {:ok, tasks} = Issues.handle(@event, @payload)

      assert Enum.count(tasks) == 3
      assert Repo.aggregate(Task, :count, :id) == 3

      tasks |> Enum.each(fn task ->
        assert task.project_id in project_ids
        assert task.markdown == markdown
        assert task.title == title
        assert task.github_id == github_id
        assert task.status == "open"
      end)

      assert existing_task_id in (tasks |> Enum.map(&Map.get(&1, :id)))
    end

    test "with matched user, returns error if unmatched repository" do
      %{"issue" => %{"user" => %{"id" => user_github_id}}} = @payload
      insert(:user, github_id: user_github_id)

      assert Issues.handle(@event, @payload) == {:error, :unmatched_repository}
    end

    test "returns error if payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, %{})
    end

    test "returns error if repo payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, @payload |> Map.put("repository", "foo"))
    end

    test "returns error if issue payload is wrong" do
      assert {:error, :unexpected_payload} == Issues.handle(@event, @payload |> Map.put("issue", "foo"))
    end
  end

  describe "handle/2 for Issues::assigned" do
    @payload %{}

    test "is not implemented" do
      event = build(:github_event, action: "assigned", type: "issues")
      assert Issues.handle(event, @payload) == {:error, :not_fully_implemented}
    end
  end

  describe "handle/2 for Issues::unassigned" do
    @payload %{}

    test "is not implemented" do
      event = build(:github_event, action: "unassigned", type: "issues")
      assert Issues.handle(event, @payload) == {:error, :not_fully_implemented}
    end
  end

  describe "handle/2 for Issues::labeled" do
    @payload %{}

    test "is not implemented" do
      event = build(:github_event, action: "labeled", type: "issues")
      assert Issues.handle(event, @payload) == {:error, :not_fully_implemented}
    end
  end

  describe "handle/2 for Issues::unlabeled" do
    @payload %{}

    test "is not implemented" do
      event = build(:github_event, action: "unlabeled", type: "issues")
      assert Issues.handle(event, @payload) == {:error, :not_fully_implemented}
    end
  end

  describe "handle/2 for Issues::milestoned" do
    @payload %{}

    test "is not implemented" do
      event = build(:github_event, action: "milestoned", type: "issues")
      assert Issues.handle(event, @payload) == {:error, :not_fully_implemented}
    end
  end

  describe "handle/2 for Issues::demilestoned" do
    @payload %{}

    test "is not implemented" do
      event = build(:github_event, action: "demilestoned", type: "issues")
      assert Issues.handle(event, @payload) == {:error, :not_fully_implemented}
    end
  end
end

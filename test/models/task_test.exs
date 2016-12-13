defmodule CodeCorps.TaskTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Task

  @valid_attrs %{
    title: "Test task",
    task_type: "issue",
    markdown: "A test task",
  }
  @invalid_attrs %{
    task_type: "nonexistent"
  }

  describe "create/2" do
    test "is invalid with invalid attributes" do
      changeset = Task.changeset(%Task{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "only allows specific values for task_type" do
      changes = Map.put(@valid_attrs, :task_type, "nonexistent")
      changeset = Task.changeset(%Task{}, changes)
      refute changeset.valid?
    end

    test "renders body html from markdown" do
      user = insert(:user)
      project = insert(:project)
      changes = Map.merge(@valid_attrs, %{
        markdown: "A **strong** body",
        project_id: project.id,
        user_id: user.id
      })
      changeset = Task.changeset(%Task{}, changes)
      assert changeset.valid?
      assert changeset |> get_change(:body) == "<p>A <strong>strong</strong> body</p>\n"
    end
  end

  describe "create_changeset/2" do
    test "is valid with valid attributes" do
      user = insert(:user)
      project = insert(:project)
      task_list = insert(:task_list)
      changeset = Task.create_changeset(%Task{}, %{
        markdown: "some content",
        task_type: "issue",
        title: "some content",
        project_id: project.id,
        user_id: user.id,
        task_list_id: task_list.id
      })
      assert changeset.valid?
    end

    test "auto-sequences number, scoped to project" do
      user = insert(:user)
      project_a = insert(:project, title: "Project A")
      project_b = insert(:project, title: "Project B")
      task_list_a = insert(:task_list, name: "Task List A", project: project_a)
      task_list_b = insert(:task_list, name: "Task List B", project: project_b)

      insert(:task, project: project_a, user: user, task_list: task_list_a, rank: 2000, title: "Project A Task 1")
      insert(:task, project: project_a, user: user, task_list: task_list_a, rank: 1000, title: "Project A Task 2")

      insert(:task, project: project_b, user: user, task_list: task_list_b, title: "Project B Task 1")

      changes = Map.merge(@valid_attrs, %{
        project_id: project_a.id,
        user_id: user.id,
        task_list_id: task_list_a.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      {:ok, result} = Repo.insert(changeset)
      assert result.number == 3

      changes = Map.merge(@valid_attrs, %{
        project_id: project_b.id,
        user_id: user.id,
        task_list_id: task_list_b.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      {:ok, result} = Repo.insert(changeset)
      assert result.number == 2
    end

    test "auto-assigns rank, beginning of list, scoped to task list" do
      user = insert(:user)
      project_a = insert(:project, title: "Project A")
      task_list_a = insert(:task_list, name: "Task List A", project: project_a)
      task_list_b = insert(:task_list, name: "Task List B", project: project_a)

      task_a_1 = insert(:task, project: project_a, user: user, task_list: task_list_a, rank: 2000, title: "Project A Task 1")
      task_a_2 = insert(:task, project: project_a, user: user, task_list: task_list_a, rank: 1000, title: "Project A Task 2")

      task_b_1 = insert(:task, project: project_a, user: user, task_list: task_list_b, rank: 2000, title: "Project B Task 1")
      task_b_2 = insert(:task, project: project_a, user: user, task_list: task_list_b, rank: 1000, title: "Project B Task 2")

      changes = Map.merge(@valid_attrs, %{
        project_id: project_a.id,
        user_id: user.id,
        task_list_id: task_list_a.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      {:ok, result_a} = Repo.insert(changeset)
      assert result_a.rank < task_a_1.rank && result_a.rank < task_a_2.rank

      changes = Map.merge(@valid_attrs, %{
        project_id: project_a.id,
        user_id: user.id,
        task_list_id: task_list_b.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      {:ok, result_b} = Repo.insert(changeset)
      assert result_b.rank < task_b_1.rank && result_b.rank < task_b_2.rank

      # Make sure that, given the same rank configuration between task lists,
      # the auto-assigned rank is the same, meaning the ranking is correctly scoped
      assert result_a.rank == result_b.rank
    end

    test "sets state to 'published'" do
      changeset = Task.create_changeset(%Task{}, %{})
      assert changeset |> get_change(:state) == "published"
    end

    test "sets status to 'open'" do
      changeset = Task.create_changeset(%Task{}, %{})
      # open is default, so we `get_field` instead of `get_change`
      assert changeset |> get_field(:status) == "open"
    end
  end
  describe "update_changeset/2" do
    test "sets state to 'edited'" do
      changeset = Task.update_changeset(%Task{}, %{})
      assert changeset |> get_change(:state) == "edited"
    end

    test "only allows specific values for status" do
      changes = Map.put(@valid_attrs, :status, "nonexistent")
      changeset = Task.update_changeset(%Task{}, changes)
      refute changeset.valid?
    end
  end

end

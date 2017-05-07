defmodule CodeCorps.TaskTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Task

  @valid_attrs %{
    title: "Test task",
    markdown: "A test task"
  }
  @invalid_attrs %{}

  describe "create/2" do
    test "is invalid with invalid attributes" do
      changeset = Task.changeset(%Task{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "renders body html from markdown" do
      user = insert(:user)
      project = insert(:project)
      task_list = insert(:task_list)
      changes = Map.merge(@valid_attrs, %{
        markdown: "A **strong** body",
        project_id: project.id,
        task_list_id: task_list.id,
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

      insert(:task, project: project_a, user: user, task_list: task_list_a, order: 2000, title: "Project A Task 1")
      insert(:task, project: project_a, user: user, task_list: task_list_a, order: 1000, title: "Project A Task 2")

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

    test "auto-assigns order, beginning of list, scoped to task list" do
      user = insert(:user)
      project_a = insert(:project, title: "Project A")
      task_list_a = insert(:task_list, name: "Task List A", project: project_a)
      task_list_b = insert(:task_list, name: "Task List B", project: project_a)

      task_a_1 = insert(:task, project: project_a, user: user, task_list: task_list_a, order: 2000, title: "Project A Task 1")
      task_a_2 = insert(:task, project: project_a, user: user, task_list: task_list_a, order: 1000, title: "Project A Task 2")

      task_b_1 = insert(:task, project: project_a, user: user, task_list: task_list_b, order: 2000, title: "Project B Task 1")
      task_b_2 = insert(:task, project: project_a, user: user, task_list: task_list_b, order: 1000, title: "Project B Task 2")

      changes = Map.merge(@valid_attrs, %{
        project_id: project_a.id,
        user_id: user.id,
        task_list_id: task_list_a.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      {:ok, result_a} = Repo.insert(changeset)
      assert result_a.order < task_a_1.order && result_a.order < task_a_2.order

      changes = Map.merge(@valid_attrs, %{
        project_id: project_a.id,
        user_id: user.id,
        task_list_id: task_list_b.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      {:ok, result_b} = Repo.insert(changeset)
      assert result_b.order < task_b_1.order && result_b.order < task_b_2.order

      # Make sure that, given the same order configuration between task lists,
      # the auto-assigned order is the same, meaning the order is correctly scoped
      assert result_a.order == result_b.order
    end

    test "repositions tasks correctly" do
      user = insert(:user)
      project = insert(:project)
      task_list = insert(:task_list, name: "Task List", project: project)

      task_1 = insert(:task, project: project, user: user, task_list: task_list, order: 1000)
      task_2 = insert(:task, project: project, user: user, task_list: task_list, order: 2000)

      task_list_2 = insert(:task_list, name: "Task List 2", project: project)
      task_3 = insert(:task, project: project, user: user, task_list: task_list_2)

      {:ok, task_1_result} =
        task_1
        |> Task.update_changeset(%{position: 0})
        |> Repo.update

      {:ok, task_2_result} =
        task_2
        |> Task.update_changeset(%{position: 1})
        |> Repo.update

      {:ok, task_3_result} =
        task_3
        |> Task.update_changeset(%{position: 2, task_list_id: task_list.id})
        |> Repo.update

      assert task_1_result.order < task_2_result.order
      assert task_2_result.order < task_3_result.order
    end

    test "sets status to 'open'" do
      changeset = Task.create_changeset(%Task{}, %{})
      # open is default, so we `get_field` instead of `get_change`
      assert changeset |> get_field(:status) == "open"
    end
  end

  describe "update_changeset/2" do
    test "only allows specific values for status" do
      changes = Map.put(@valid_attrs, :status, "nonexistent")
      changeset = Task.update_changeset(%Task{}, changes)
      refute changeset.valid?
    end
  end
end

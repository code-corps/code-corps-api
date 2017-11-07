defmodule CodeCorps.TaskTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Task
  alias Ecto.Changeset

  @valid_attrs %{
    title: "Test task",
    markdown: "A test task"
  }
  @invalid_attrs %{}

  describe "changeset/2" do
    test "is invalid with invalid attributes" do
      changeset = Task.changeset(%Task{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "renders body html from markdown" do
      changes = Map.merge(@valid_attrs, %{
        markdown: "A **strong** body",
        project_id: 1,
        task_list_id: 1,
        user_id: 1
      })
      changeset = Task.changeset(%Task{}, changes)
      assert changeset.valid?
      assert changeset |> get_change(:body) == "<p>A <strong>strong</strong> body</p>\n"
    end

    test "removes the order and task list when the task is archived" do
      changes = Map.put(@valid_attrs, :archived, true)
      changeset = Task.update_changeset(%Task{order: 1, task_list_id: 1}, changes)
      %{archived: archived, order: order, task_list_id: task_list_id} = changeset.changes
      assert changeset.valid?
      assert archived
      refute order
      refute task_list_id
    end

    test "validates task list when the task is not archived and position is set" do
      changes = Map.merge(@valid_attrs, %{
        position: 1,
        project_id: 1,
        user_id: 1
      })
      changeset = Task.changeset(%Task{}, changes)
      refute changeset.valid?
      assert changeset.errors[:task_list_id]
    end
  end

  describe "create_changeset/2" do
    test "sets created_at and modified_at to the same time" do
      project = insert(:project)
      task_list = insert(:task_list)
      user = insert(:user)
      changes = Map.merge(@valid_attrs, %{
        project_id: project.id,
        task_list_id: task_list.id,
        user_id: user.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      assert changeset.valid?
      {:ok, %Task{created_at: created_at, modified_at: modified_at}} = Repo.insert(changeset)
      assert created_at == modified_at
    end

    test "sets modified_from to 'code_corps'" do
      assert(
        %Task{}
        |> Task.create_changeset(%{})
        |> Changeset.get_field(:modified_from) == "code_corps"
      )
    end

    test "sets the order when the task is not archived and position is set" do
      project = insert(:project)
      task_list = insert(:task_list)
      insert(:task, task_list: task_list, order: 1)
      user = insert(:user)
      changes = Map.merge(@valid_attrs, %{
        position: 1,
        project_id: project.id,
        task_list_id: task_list.id,
        user_id: user.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      assert changeset.valid?
      {:ok, %Task{order: order}} = Repo.insert(changeset)

      # We really want to test the order is set, but we have no good way to
      # test this since the column default is `0`
      assert order !== 0
    end
  end

  describe "update_changeset/2" do
    test "only allows specific values for status" do
      changes = Map.put(@valid_attrs, :status, "nonexistent")
      changeset = Task.update_changeset(%Task{task_list_id: 1}, changes)
      refute changeset.valid?
    end

    test "closed_at is set when status changes to closed" do
      changes = Map.put(@valid_attrs, :status, "closed")
      changeset = Task.update_changeset(%Task{task_list_id: 1}, changes)
      %{closed_at: closed_at} = changeset.changes
      assert changeset.valid?
      assert closed_at
    end

    test "closed_at is set to nil when status changes to open" do
      changes = Map.put(@valid_attrs, :status, "open")
      changeset = Task.update_changeset(%Task{task_list_id: 1, status: "closed", closed_at: DateTime.utc_now}, changes)
      %{closed_at: closed_at} = changeset.changes
      assert changeset.valid?
      refute closed_at
    end

    test "archived field changes appropriately" do
      changes = Map.put(@valid_attrs, :archived, true)
      changeset = Task.update_changeset(%Task{task_list_id: 1}, changes)
      %{archived: archived} = changeset.changes
      assert changeset.valid?
      assert archived
    end

    test "does not reset order when task was already archived" do
      project = insert(:project)
      user = insert(:user)
      changes = Map.merge(@valid_attrs, %{
        archived: true,
        position: 1,
        project_id: project.id,
        user_id: user.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      {:ok, %Task{order: order} = task} = Repo.insert(changeset)
      refute order

      changeset = Task.update_changeset(task, %{title: "New title"})
      {:ok, %Task{order: order}} = Repo.update(changeset)
      refute order
    end

    test "sets :modified_from to 'code_corps'" do
      assert(
        :task
        |> insert(modified_from: "github")
        |> Task.update_changeset(%{})
        |> Changeset.get_field(:modified_from) == "code_corps"
      )
    end
  end
end

defmodule CodeCorps.TaskTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Task

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
  end
end

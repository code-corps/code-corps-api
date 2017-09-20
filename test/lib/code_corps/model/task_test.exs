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

  describe "update_changeset/2" do
    test "only allows specific values for status" do
      changes = Map.put(@valid_attrs, :status, "nonexistent")
      changeset = Task.update_changeset(%Task{}, changes)
      refute changeset.valid?
    end

    test "sets task_updated_at" do
      changeset = Task.update_changeset(%Task{}, @valid_attrs)
      assert changeset |> get_change(:task_updated_at)
    end
  end
end

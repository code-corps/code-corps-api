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
      changeset = Task.create_changeset(%Task{}, %{
        markdown: "some content",
        task_type: "issue",
        title: "some content",
        project_id: project.id,
        user_id: user.id,
      })
      assert changeset.valid?
    end

    test "auto-sequences number, scoped to project" do
      user = insert(:user)
      project_a = insert(:project, title: "Project A")
      project_b = insert(:project, title: "Project B")

      insert(:task, project: project_a, user: user, title: "Project A Task 1")
      insert(:task, project: project_a, user: user, title: "Project A Task 2")

      insert(:task, project: project_b, user: user, title: "Project B Task 1")

      changes = Map.merge(@valid_attrs, %{
        project_id: project_a.id,
        user_id: user.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      {:ok, result} = Repo.insert(changeset)
      assert result.number == 3

      changes = Map.merge(@valid_attrs, %{
        project_id: project_b.id,
        user_id: user.id
      })
      changeset = Task.create_changeset(%Task{}, changes)
      {:ok, result} = Repo.insert(changeset)
      assert result.number == 2
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
